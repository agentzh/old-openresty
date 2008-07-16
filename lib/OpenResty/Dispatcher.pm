package OpenResty::Dispatcher;

use strict;
use warnings;

#use Smart::Comments '####';
use Cookie::XS;
use OpenResty::Limits;
use OpenResty::Cache;
use OpenResty;
use OpenResty::Inlined;
use OpenResty::Config;
use File::Spec;

our $InitFatal;
our $StatsLog;

# XXX Excpetion not caputred...when database 'test' not created.
my %Dispatcher = (
    model => [
        qw< model_list model model_column model_row >
    ],
    view => [
        qw< view_list view view_param view_exec >
    ],
    feed => [
        qw< feed_list feed feed_param feed_exec >
    ],
    action => [
        qw< action_list action action_param action_exec  >
    ],
    unsafe => [
        qw< unsafe unsafe_op >
    ],
    role => [
        qw< role_list role access_rule_column access_rule >
    ],
    login => [
        qw< login login_user login_user_password >
    ],
    captcha => [
        qw< captcha_list captcha_column captcha_value >
    ],
    version => [ qw< version > ],
);

my $url_prefix = $ENV{OPENRESTY_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

sub init {
    my ($class, $context) = @_;
    #warn "init: $backend\n";
    eval {
        OpenResty::Config->init;
        my $backend = $OpenResty::Config{'backend.type'};
        $OpenResty::Cache = OpenResty::Cache->new;
        OpenResty->connect($backend);
    };
    if ($@) { $InitFatal = $@; return; }
    #warn "InitFatal: $InitFatal\n";

    if (!$context || ($context ne 'upgrade' && $context !~ /user/)) {
        eval {
            my $backend = $OpenResty::Backend;
            $backend->set_user('_global');
            my $base = $backend->get_upgrading_base;
            #warn "BASE: $base\n";
            if ($base >= 0) {
                die "The server's global MetaModel is out of date. ",
                    "Please run the command \"bin/openresty upgrade\" first.\n";
            }
        };
        if ($@) {
            $InitFatal = $@;
        }
    }

    eval {
        $OpenResty::Backend->set_user('_global');
        $OpenResty::Backend->do('set lc_messages to "C";');
    };
    if ($@ && $context !~ /user/) { warn $@ }

    $StatsLog = $OpenResty::Config{'frontend.stats_log_dir'};
    if ($StatsLog && !-d $StatsLog) {
        mkdir $StatsLog or
            die "Can't create directory $StatsLog: $!\n";
    }

    if (my $filtered = $OpenResty::Config{'frontend.filtered'}) {
        #warn "HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
        #use lib "$FindBin::Bin/../../../openresty-filter-qp/trunk/lib";
        $filtered =~ s/^\s+|\s+$//g;
        require OpenResty::Filter::QP;
        my @accounts = split /\s+/, $filtered;
        for my $account (@accounts) {
            $OpenResty::AccountFiltered{$account} = 1;
        }
        #### %OpenResty::AccountFiltered
        ### $filtered
    }
    if (my $unsafe_accounts = $OpenResty::Config{'frontend.unsafe'}) {
        $unsafe_accounts =~ s/^\s+|\s+$//g;
        my @accounts = split /\s+/, $unsafe_accounts;
        for my $account (@accounts) {
            $OpenResty::UnsafeAccounts{$account} = 1;
        }
    }
}

sub process_request {
    my ($class, $cgi, $call_level, $parent_account) = @_;

    $call_level ||= 0;

    if ($call_level > $ACTION_REC_DEPTH_LIMIT) {
        die "Action calling chain is too deep. (The limit is $ACTION_REC_DEPTH_LIMIT.)\n";
    }

    my $url  = $ENV{REQUEST_URI};
    ### $url
    $url =~ s/\?.*//g;
    #my $url = $cgi->url(-absolute=>1,-path_info=>1);
    $url =~ s{^/+}{}g;
    ### Old URL: $url
    ### URL Prefox: $url_prefix

    $url =~ s{^\Q$url_prefix\E/+}{}g if $url_prefix;    ### New URL: $url

    my $openresty;
    if ($call_level == 0) {
        $openresty = OpenResty->new($cgi, $call_level);
    } else {
        $openresty = OpenResty::Inlined->new($cgi, $call_level);
    }

    #warn "InitFatal2: $InitFatal\n";
    eval {
        $openresty->init(\$url);
    };
    if ($@) {
        ### Exception in new: $@
        return $openresty->fatal($@);
    }

    if ($InitFatal) {
        return $openresty->fatal($InitFatal);
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;

    if (!@bits) {
        ### Unknown URL: $url
        return $openresty->fatal("Unknown URL: $url");
    }

    map { s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; } @bits;
    ## @bits

    my $fst = shift @bits;
    if ($fst ne '=') {
        return $openresty->fatal("URLs must be led by '=': $url");
    }

    my $key = $bits[0];
    if (!defined $key) { $key = $bits[0] = 'version'; }

    my $http_meth = $openresty->{'_http_method'};
    if (!$http_meth) {
        return $openresty->fatal("HTTP method not detected.");
    }
    ### $http_meth
    if ($call_level == 0 && $OpenResty::Config{'frontend.log'}) {
        require Clone;
        #warn "------------------------------------------------\n";
        warn "$http_meth $ENV{REQUEST_URI} (", join("/", @bits), ")\n";
        my $data = Clone::clone($openresty->{_req_data});
        Data::Structure::Util::_utf8_on($data);
        warn $OpenResty::Dumper->($data), "\n"
            if $http_meth eq 'POST' or $http_meth eq 'PUT';
    }

    # XXX hacks...
    my ($session, $session_from_cookie);
    if ($call_level == 0) { # only check cookies on the toplevel call
        my $cookies = Cookie::XS->fetch;
        if ($cookies) {
            my $cookie = $cookies->{session};
            if ($cookie) {
                $openresty->{_session_from_cookie} =
                    $session_from_cookie = $cookie->[-1];
            }
        }
    }

    if ($http_meth eq 'GET' and @bits >= 2 and $bits[0] eq 'last' and $bits[1] eq 'response') {
        my $last_res_id = $bits[2];
        if (!$last_res_id) {
            $openresty->fatal("No last response ID specified.");
            return;
        }
        my $res = $OpenResty::Cache->get_last_res($last_res_id);
        if (!defined $res) {
            $openresty->fatal("No last response found for ID $last_res_id");
            return;
        }
        $openresty->{_bin_data} = $res . "\n";
        $openresty->response;
        #warn "last_response: $response_from_cookie\n";
        return;
    }

    $session = $openresty->{_session} || $session_from_cookie;
    if ($key eq 'logout') {
        ### Yeah yeah yeah!
        if ($session) {
            $OpenResty::Cache->remove($session);
        }
        $openresty->{_bin_data} = "{\"success\":1}\n";
        return $openresty->response;
    }

    my ($account, $role);
    if ($key !~ /^(?:login|captcha|version)$/) {
        eval {
            # XXX this part is lame...
            my $user = $cgi->url_param('user');
            if (defined $user) {
                #$OpenResty::Cache->remove($uuid);
                my $captcha = $cgi->url_param('captcha');
                ### URL param capture: $captcha
                require OpenResty::Handler::Login;
                my $res = OpenResty::Handler::Login->login($openresty, $user, {
                    password => scalar($cgi->url_param('password')),
                    captcha => $captcha,
                });
                $account = $res->{account};
                $role = $res->{role};
                # XXX login as $account.$role...
                # XXX if account is anonymous, then create a session
                # XXX else check password, if correct, create a session
            } else {
                ### First bit: $bits[0]
                if ($session) {
                    my $user = $OpenResty::Cache->get($session);
                    ### User from cookie: $user
                    if ($user) {
                        ($account, $role) = split /\./, $user, 2;
                    }
                    ### $account
                    ### $role
                }
            }

            if ($call_level == 0) {
                # this part is lame?
                if (!$account) {
                    die "Login required.\n";
                }
                if (!$openresty->has_user($account)) {
                    ### Found user: $user
                    die "Account \"$account\" does not exist.\n";
                }
            } else {
                if (!$account) {
                    $account = $parent_account;
                } else {
                    if (!$openresty->has_user($account)) {
                        ### Found user: $user
                        die "Account \"$account\" does not exist.\n";
                    }
                }
            }
            $openresty->set_user($account);

            $role ||= 'Admin';
            if (!$openresty->has_role($role)) {
                ### Found user: $user
                die "Role \"$role\" does not exist.\n";
            }
            $openresty->set_role($role);
        };
        if ($@) {
            return $openresty->fatal($@);
        }
    }

    # XXX check ACL rules...
    if (!defined $role || $role ne 'Admin') {
        if ($key !~ /^(?:login|logout|captcha|version)$/) {
            my $res = $openresty->current_user_can($http_meth => \@bits);
            if (!$res) {
                return $openresty->fatal("Permission denied for the \"$role\" role.");
            }
        }
    }

    my $category = $Dispatcher{$key};
    if ($category) {
        my $object = $category->[$#bits];
        ### $object
        if (!defined $object) {
            return $openresty->fatal("Unknown URL level: $url");
        }
        my $package = 'OpenResty::Handler::' . ucfirst($key);
        eval "use $package";
        if ($@) {
            return $openresty->fatal("Failed to load $package");
        }
        my $meth = $http_meth . '_' . $object;
        $meth =~ s/\./_/g;
        if (!$package->can($meth)) {
            $object =~ s/_/ /g;
            return $openresty->fatal("HTTP $http_meth method not supported for $object.");
        }
        my $data;
        eval {
            if ($key eq 'model') {
                $package->global_model_check($openresty, \@bits, $http_meth);
            }

            $data = $package->$meth($openresty, \@bits);
        };
        if ($@) {
            return $openresty->fatal($@);
        }
        $openresty->data($data);
        $openresty->response();
    } else {
        $openresty->fatal("Unknown URL catagory: $key");
    }
}

1;
__END__

=head1 NAME

OpenResty::Dispatcher - The main dispatcher for the OpenResty server

=head1 SYNOPSIS

    use OpenResty::Dispatcher;

    OpenResty::Dispatcher->init($context);
         # $context is the bin/openresty script's input command,
         #   like 'fastcgi', 'cgi', or 'upgrade'.

    my $res = OpenResty::Dispatcher->process_request($cgi);

=head1 DESCRIPTION

=head1 METHODS

All the methods below are static. This class has no instances.

=over

=item C<init($context)>

Connects to the database and preserving the global database connection, reads the config options, checks the metamodel version if C<$context> is not "C<upgrade>", and does other initialization jobs.

=item C<$res = process_request($cgi, $call_level, $parent_account)>

Process the incoming OpenResty RESTful request (not necessarily HTTP requests though). The first argument is a CGI object while the latter two only make sense in recursive calls issued by OpenRsety actions.

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>.

=head1 SEE ALSO

L<OpenResty>.

