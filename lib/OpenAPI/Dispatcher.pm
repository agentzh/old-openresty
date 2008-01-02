package OpenAPI::Dispatcher;

use strict;
use warnings;
use OpenAPI::Limits;
use OpenAPI;

our $DBFatal;

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
        qw< role_list role access_rule_col access_rule >
    ],
    login => [
        qw< login login_user login_user_password >
    ],
);

my $url_prefix = $ENV{OPENAPI_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

sub init {
    $CGI::POST_MAX = 100 * 1024;  # max 100 K posts
    $CGI::DISABLE_UPLOADS = 1;  # no uploads
    my $backend = $ENV{OPENAPI_BACKEND} || 'Pg';
    eval {
        OpenAPI->connect($backend);
    };
    if ($@) {
        $DBFatal = $@;
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

    my $openapi = OpenAPI->new($cgi);
    if ($DBFatal) {
        $openapi->fatal($DBFatal);
        return;
    }

    # XXX this part is lame...
    my $user = $cgi->url_param('user') || 'peee';
    ### $user
    eval {
        #OpenAPI->drop_user($user);
    };
    if ($@) {
        $openapi->fatal($@);
        warn $@;
        next;
    }
    if (my $retval = OpenAPI->has_user($user)) {
        ### Found user: $user
    } else {
        ### Creating new user: $user
        eval {
            $openapi->add_user($user);
        };
        if ($@) {
            warn $@;
            $openapi->fatal($@);
            next;
        }
    }

    eval {
        OpenAPI->set_user($user);
    };
    if ($@) {
        $openapi->fatal($@);
        return ;
    }

    eval {
        $openapi->init(\$url);
    };
    if ($@) {
        ### Exception in new: $@
        $openapi->fatal($@);
        return;
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;

    if (!@bits) {
        ### Unknown URL: $url
        $openapi->fatal("Unknown URL: $url");
        return;
    }

    map { s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; } @bits;
    ### @bits

    my $fst = shift @bits;
    if ($fst ne '=') {
        $openapi->fatal("URLs must be led by '=': $url");
        return;
    }

    my $http_meth = $openapi->{'_http_method'};
    if (!$http_meth) {
        $openapi->fatal("HTTP method not detected.");
        return;
    }

    my ($account, $role);
    my $cookies = CGI::Cookie->fetch;
    if ($cookies) {
        my $cookie = $cookies->{account};
        if ($cookie) {
            $account = $cookie->value;
        }
        $cookie = $cookies->{role};
        if ($cookie) {
            $role = $cookie->value;
        }
    }

    # XXX hacks...
    $account ||= $user;
    $role ||= 'Admin';
    $openapi->set_role($role);

    my $category = $Dispatcher{$bits[0]};

    # XXX check ACL rules...
    if ($bits[0] and $bits[0] ne 'login') {
        my $res = $openapi->current_user_can($http_meth => \@bits);
        if (!$res) {
            $openapi->fatal("Permission denied for the \"$role\" role.");
            return;
        }
    }

    if ($category) {
        my $object = $category->[$#bits];
        ### $object
        if (!defined $object) {
            $openapi->fatal("Unknown URL level: $url");
            return;
        }
        my $meth = $http_meth . '_' . $object;
        $meth =~ s/\./_/g;
        if (!$openapi->can($meth)) {
            $object =~ s/_/ /g;
            $openapi->fatal("HTTP $http_meth method not supported for $object.");
            return;
        }
        my $data;
        eval {
            if ($bits[0] eq 'model') {
                $openapi->global_model_check(\@bits, $http_meth);
            }

            $data = $openapi->$meth(\@bits);
        };
        if ($@) {
            $openapi->fatal($@);
            return;
        }
        $openapi->data($data);
        $openapi->response();
    } else {
        $openapi->fatal("Unknown URL catagory: $bits[0]");
    }

}

1;
