#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/../lib";
use OpenAPI;
#use Web::Scraper;
use CGI::Fast ();
use Data::Dumper;
use OpenAPI::Limits;
#use XML::Simple qw(:strict);
use FindBin;
#use Perl6::Say;

$CGI::POST_MAX = 100 * 1024;  # max 100 K posts
$CGI::DISABLE_UPLOADS = 1;  # no uploads
my $DBFatal;

# XXX Excpetion not caputred...when database 'test' not created.
my $backend = $ENV{OPENAPI_BACKEND} || 'Pg';
eval {
    OpenAPI->connect($backend);
};
if ($@) {
    $DBFatal = $@;
}

my %Dispatcher = (
    model => [
        qw< model_list model model_column model_row >
    ],
    view => [
        qw< view_list view view_exec view_exec_with_param >
    ],
    action => [
        qw< action_list action action_param action_exec  >
    ],
    admin => [
        qw< admin admin_op >
    ]
);

my $url_prefix = $ENV{OPENAPI_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

while (my $cgi = new CGI::Fast) {
    my $url  = $ENV{REQUEST_URI};
    ### $url
    $url =~ s/\?.*//g;
    #my $url = $cgi->url(-absolute=>1,-path_info=>1);
    $url =~ s{^/+}{}g;
    ### Old URL: $url
    ### URL Prefox: $url_prefix

    $url =~ s{^\Q$url_prefix\E/+}{}g if $url_prefix;
    ### New URL: $url

    my $openapi = OpenAPI->new($cgi);
    if ($DBFatal) {
        $openapi->fatal($DBFatal);
        next;
    }

    # XXX this part is lame...
    my $user = $cgi->url_param('user') || 'tester';
    ### $user
    eval {
        #OpenAPI->drop_user($user);
    };
    if ($@) { warn $@; }
    if (my $retval = OpenAPI->has_user($user)) {
        ### Found user: $user
    } else {
        ### Creating new user: $user
        eval {
            $openapi->add_user($user);
        };
        if ($@) {  warn $@; }
    }

    eval {
        OpenAPI->set_user($user);
    };
    if ($@) {
        $openapi->fatal($@);
        next;
    }

    eval {
        $openapi->init(\$url);
    };
    if ($@) {
        ### Exception in new: $@
        $openapi->fatal($@);
        next;
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;
	
    if (!@bits) {
        ### Unknown URL: $url
        $openapi->fatal("Unknown URL: $url");
        next;
    }

    map { s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; } @bits;
    ### @bits

    my $fst = shift @bits;
    if ($fst ne '=') {
        $openapi->fatal("URLs must be led by '='.");
        next;
    }

    my $http_meth = $openapi->{'_http_method'};
    if (!$http_meth) {
        $openapi->fatal("HTTP method not detected.");
        next;
    }

    my $category = $Dispatcher{$bits[0]};
    if ($category) {
        my $object = $category->[$#bits];
        ### $object
        if (!defined $object) {
            $openapi->fatal("Unknown URL level: $url");
            next;
        }
        my $meth = $http_meth . '_' . $object;
        $meth =~ s/\./_/g;
        if (!$openapi->can($meth)) {
            $object =~ s/_/ /g;
            $openapi->fatal("HTTP $http_meth method not supported for $object.");
            next;
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
            next;
        }
        $openapi->data($data);
        $openapi->response();
    } else {
        $openapi->fatal("Unknown URL catagory: $bits[0]");
    }
}

