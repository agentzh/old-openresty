package OpenResty::Dispatcher;

use strict;
use warnings;

#use Smart::Comments '####';
use Cookie::XS;
use OpenResty::Limits;
use OpenResty::Cache;
use OpenResty;
use OpenResty::Config;

our $InitFatal;

# XXX Excpetion not caputred...when database 'test' not created.
my %Dispatcher = (
    model => [
        qw< model_list model model_column model_row >
    ],
    view => [
        qw< view_list view view_param view_exec >
    ],
    action => [
        qw< action_list action action_param action_exec  >
    ],
    admin => [
        qw< admin admin_op >
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

my $url_prefix = $ENV{OPENAPI_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

sub init {
    OpenResty::Config->init;
    my $backend = $OpenResty::Config{'backend.type'};
    eval {
        $OpenResty::Cache = OpenResty::Cache->new;
        OpenResty->connect($backend);
    };
    if ($@) { $InitFatal = $@; }

    if (my $filtered = $OpenResty::Config{'frontend.filtered'}) {
        #warn "HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
        use lib "$FindBin::Bin/../../../openresty-filter-qp/trunk/lib";
        require OpenResty::Filter::QP;
        my @accounts = split /\s+/, $filtered;
        for my $account (@accounts) {
            $OpenResty::AccountFiltered{$account} = 1;
        }
        #### %OpenResty::AccountFiltered
        ### $filtered
    }
}

sub process_request {
    my ($class, $cgi) = @_;
    my $url  = $ENV{REQUEST_URI};
    ### $url
    $url =~ s/\?.*//g;
    #my $url = $cgi->url(-absolute=>1,-path_info=>1);
    $url =~ s{^/+}{}g;
    ### Old URL: $url
    ### URL Prefox: $url_prefix

    $url =~ s{^\Q$url_prefix\E/+}{}g if $url_prefix;    ### New URL: $url

    my $openresty = OpenResty->new($cgi);
    if ($InitFatal) {
        $openresty->fatal($InitFatal);
        return;
    }

    eval {
        $openresty->init(\$url);
    };
    if ($@) {
        ### Exception in new: $@
        $openresty->fatal($@);
        return;
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;

    if (!@bits) {
        ### Unknown URL: $url
        $openresty->fatal("Unknown URL: $url");
        return;
    }

    map { s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; } @bits;
    ## @bits

    my $fst = shift @bits;
    if ($fst ne '=') {
        $openresty->fatal("URLs must be led by '=': $url");
        return;
    }

    my $key = $bits[0];
    if (!defined $key) { $key = $bits[0] = 'version'; }

    my $http_meth = $openresty->{'_http_method'};
    if (!$http_meth) {
        $openresty->fatal("HTTP method not detected.");
        return;
    }
    ### $http_meth
    if ($OpenResty::Config{'frontend.log'}) {
        require Clone;
        #warn "------------------------------------------------\n";
        warn "$http_meth ", $ENV{REQUEST_URI}, "\n";
        warn JSON::Syck::Dump(Clone::clone($openresty->{_req_data})), "\n"
            if $http_meth eq 'POST' or $http_meth eq 'PUT';
    }

    # XXX hacks...
    my $cookies = Cookie::XS->fetch;
    my ($session_from_cookie, $captcha_from_cookie);
    my $session;
    if ($cookies) {
        my $cookie = $cookies->{session};
        if ($cookie) {
            $openresty->{_session_from_cookie} =
                $session_from_cookie = $cookie->[-1];
        }
        $cookie = $cookies->{captcha};
        if ($cookie) {
            $openresty->{_captcha_from_cookie} =
                $captcha_from_cookie = $cookie->[-1];
            #$OpenResty::Cache->remove($captcha_from_cookie);
        }
    }

    if ($http_meth eq 'GET' and @bits >= 2 and $bits[0] eq 'last' and $bits[1] eq 'response') {
        my $last_res_id = $bits[2];
        if (!$last_res_id) {
            $openresty->fatal("No last response ID specified.");
            return;
        }
        my $res = $OpenResty::Cache->get("lastres:".$last_res_id);
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
        $openresty->response;
        return;
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

            # this part is lame?
            if (!$account) {
                die "Login required.\n";
            }
            if (!$openresty->has_user($account)) {
                ### Found user: $user
                die "Account \"$account\" does not exist.\n";
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
            $openresty->fatal($@);
            return;
        }
    }

    # XXX check ACL rules...
    if ($key !~ /^(?:login|logout|captcha|version)$/) {
        my $res = $openresty->current_user_can($http_meth => \@bits);
        if (!$res) {
            $openresty->fatal("Permission denied for the \"$role\" role.");
            return;
        }
    } else {
    }

    my $category = $Dispatcher{$key};
    if ($category) {
        my $object = $category->[$#bits];
        ### $object
        if (!defined $object) {
            $openresty->fatal("Unknown URL level: $url");
            return;
        }
        my $package = 'OpenResty::Handler::' . ucfirst($key);
        eval "use $package";
        if ($@) {
            $openresty->fatal("Failed to load $package");
            return;
        }
        my $meth = $http_meth . '_' . $object;
        $meth =~ s/\./_/g;
        if (!$package->can($meth)) {
            $object =~ s/_/ /g;
            $openresty->fatal("HTTP $http_meth method not supported for $object.");
            return;
        }
        my $data;
        eval {
            if ($key eq 'model') {
                $package->global_model_check($openresty, \@bits, $http_meth);
            }

            $data = $package->$meth($openresty, \@bits);
        };
        if ($@) {
            $openresty->fatal($@);
            return;
        }
        $openresty->data($data);
        $openresty->response();
    } else {
        $openresty->fatal("Unknown URL catagory: $key");
    }
}

1;
