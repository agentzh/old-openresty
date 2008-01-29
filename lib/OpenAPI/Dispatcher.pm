package OpenAPI::Dispatcher;

use strict;
use warnings;

#use Smart::Comments;
use OpenAPI::Cookie;
use Data::UUID;
use OpenAPI::Limits;
use OpenAPI::Cache;
use OpenAPI;
use OpenAPI::Config;

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
    OpenAPI::Config->init;
    my $backend = $OpenAPI::Config{'backend.type'};
    eval {
        $OpenAPI::Cache = OpenAPI::Cache->new;
        OpenAPI->connect($backend);
    };
    if ($@) {
        $InitFatal = $@;
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
    if ($InitFatal) {
        $openapi->fatal($InitFatal);
        return;
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
    ## @bits

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
    ### $http_meth

    # XXX hacks...
    my $cookies = OpenAPI::Cookie->fetch;
    my ($session_from_cookie, $captcha_from_cookie, $response_from_cookie);
    my $session;
    if ($cookies) {
        my $cookie = $cookies->{session};
        if ($cookie) {
            $openapi->{_session_from_cookie} =
                $session_from_cookie = $cookie->[-1];
        }
        $cookie = $cookies->{captcha};
        if ($cookie) {
            $openapi->{_captcha_from_cookie} =
                $captcha_from_cookie = $cookie->[-1];
            #$OpenAPI::Cache->remove($captcha_from_cookie);
        }
        if ($cookie = $cookies->{last_response}) {
            $response_from_cookie = $cookie->[-1];
        }
    }

    if ($http_meth eq 'GET' and @bits >= 2 and $bits[0] eq 'last' and $bits[1] eq 'response') {
        $openapi->{_bin_data} = $response_from_cookie . "\n";
        $openapi->response;
        return;
    }

    $session = $openapi->{_session} || $session_from_cookie;
    if ($bits[0] eq 'logout') {
        ### Yeah yeah yeah!
        if ($session) {
            $OpenAPI::Cache->remove($session);
        }
        $openapi->{_bin_data} = "{\"success\":1}\n";
        $openapi->response;
        return;
    }

    my ($account, $role);
    if ($bits[0] and $bits[0] !~ /^(?:login|captcha|version)$/) {
        eval {
            # XXX this part is lame...
            my $user = $cgi->url_param('user');
            if (defined $user) {
                #$OpenAPI::Cache->remove($uuid);
                my $captcha = $cgi->url_param('captcha');
                ### URL param capture: $captcha
                my $res = $openapi->login($user, {
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
                    my $user = $OpenAPI::Cache->get($session);
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
            if (!$openapi->has_user($account)) {
                ### Found user: $user
                die "Account \"$account\" does not exist.\n";
            }
            $openapi->set_user($account);

            $role ||= 'Admin';
            if (!$openapi->has_role($role)) {
                ### Found user: $user
                die "Role \"$role\" does not exist.\n";
            }
            $openapi->set_role($role);
        };
        if ($@) {
            $openapi->fatal($@);
            return;
        }
    }

    # XXX check ACL rules...
    if ($bits[0] and $bits[0] !~ /^(?:login|logout|captcha|version)$/) {
        my $res = $openapi->current_user_can($http_meth => \@bits);
        if (!$res) {
            $openapi->fatal("Permission denied for the \"$role\" role.");
            return;
        }
    } else {
    }

    my $category = $Dispatcher{$bits[0]};
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
