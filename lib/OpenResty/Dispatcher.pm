package OpenResty::Dispatcher;

use strict;
use warnings;

our %Handlers;

#use Smart::Comments '####';
use CGI::Cookie::XS;
use OpenResty::Limits;
use OpenResty::Cache;
use OpenResty;
use OpenResty::Inlined;
use OpenResty::Config;
use File::Spec;

our $InitFatal;
our $StatsLog;
our $Context;

# XXX Excpetion not caputred...when database 'test' not created.

my $url_prefix = $ENV{OPENRESTY_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

sub init {
    my ($class, $opts) = @_;

    my $context = $opts->{context};
    if (defined $context) {
        $Context = $context;
    } else {
        $context = $Context;
    }
    
    undef $InitFatal;

    eval {
        OpenResty::Config->init($opts);
        my $backend = $OpenResty::Config{'backend.type'};
        $OpenResty::Cache = OpenResty::Cache->new;
        OpenResty->connect($backend);
    };
    if ($@) { 
        # warn $@; 
        $InitFatal = $@; 
        return; 
    }
    #warn "InitFatal: $InitFatal\n";

    if (!$context || ($context ne 'upgrade' && $context !~ /user/)) {
        eval {
            my $backend = $OpenResty::Backend;
            $backend->set_user('_global');
            my $base = $backend->get_upgrading_base;
            #warn "BASE: $base\n";
            if ($base >= 0) {
                warn "The server's global MetaModel is out of date. ",
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

    my $hdls = $OpenResty::Config{'frontend.handlers'};
    my @handlers;
    if (!defined $hdls) {
        @handlers = qw<
            Model View Feed Action Role Unsafe Login
            Captcha Version LastResponse
        >;
    } else {
        @handlers = split /\s+|\s*,\s*/, $hdls;
    }
    for my $hdl (@handlers) {
        eval "use OpenResty::Handler::$hdl";
        if ($@) {
            $InitFatal = "Failed to load handler class OpenResty::Handler::$hdl: $@\n";
            last;
        }
    }
}

sub process_request {
    my ($class, $cgi, $call_level, $parent_account) = @_;

    if ($InitFatal) {
        # warn "Init error: $InitFatal";
        warn "Found init fatal error. Now we re-init the dispatcher...\n";
        
        $class->init({'context' => $Context});
    }

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
    $openresty->{_call_level} = $call_level;
    $openresty->{_parent_account} = $parent_account;

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

    if (scalar(@bits) == 4 && $bits[2] =~ m{^_\w+} ) {
        # warn $openresty->{_builtin_params};
        $openresty->{_builtin_params}->{$bits[2]} = $bits[3];
        $bits[2] = '~';
        $bits[3] = '~';
    }
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

    my $category = $key;
    if ($category) {
        my $package = $Handlers{$category};
        #### handlers: %Handlers
        #eval "use $package";
        if (!defined $package) {
            return $openresty->fatal("Handler for the \"$category\" category not found.\n");
        }
        if ($package->requires_acl) {
            my $res;
            eval {
                my $login_pkg = $Handlers{login};
                if (!$login_pkg) { die "Login handler not loaded.\n" }
                my $role_pkg = $Handlers{role};
                if (!$role_pkg) { die "Role handler not loaded.\n" }
                OpenResty::Handler::Login->login_per_request($openresty, \@bits);
                $res = OpenResty::Handler::Role->current_user_can($openresty, $http_meth => \@bits);
            };
            if ($@) {
                return $openresty->fatal($@);
            }
            if (!$res) {
                my $role = $openresty->{_role};
                return $openresty->fatal("Permission denied for the \"$role\" role.");
            }
        }
        my $data;
        eval {
            #my $hdl = $package;
            # XXX global_model_check is a hack...
            if ($key eq 'model') {
                $package->global_model_check($openresty, \@bits, $http_meth);
            }
            $data = $package->go($openresty, $http_meth, \@bits);
        };
        if ($@) {
            return $openresty->fatal($@);
        }
        $openresty->data($data);
        return $openresty->response();
    } else {
        return $openresty->fatal("Unknown URL catagory: $category");
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

