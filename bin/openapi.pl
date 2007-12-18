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

my @ModelDispatcher = qw(
    model_list model model_column model_row
);

my $url_prefix = $ENV{OPENAPI_URL_PREFIX};
if ($url_prefix) {
    $url_prefix =~ s{^/+|/+$}{}g;
}

my $ext = qr/\.(?:js|json|xml|yaml|yml)/;
while (my $cgi = new CGI::Fast) {
    #my $url  = $ENV{REQUEST_URI};
    #$url =~ s/\?.*//g;
    my $url = $cgi->url(-absolute=>1,-path_info=>1);
    $url =~ s{^/+}{}g;
    ### Old URL: $url
    ### URL Prefox: $url_prefix
    #print header(-type => 'text/plain; charset=UTF-8');
    #die $url;

    $url =~ s{^\Q$url_prefix\E/+}{}g if $url_prefix;
    ### New URL: $url

    my $openapi = OpenAPI->new($cgi);
    if ($DBFatal) {
        $openapi->error($DBFatal);
        $openapi->response();
    }

    # XXX this part is lame...
    my $user = $cgi->url_param('user') || 'peee';
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
        $openapi->error($@);
        $openapi->response();
        next;
    }

    eval {
        $openapi->init(\$url);
    };
    if ($@) {
        ### Exception in new: $@
        $openapi->error($@);
        $openapi->response();
        next;
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;
    if (!@bits) {
        ### Unknown URL: $url
        $openapi->error("Unknown URL: $url");
        $openapi->response();
        next;
    }
    ### @bits
    my $fst = shift @bits;
    if ($fst ne '=') {
        $openapi->error("URLs must be led by '='.");
        $openapi->response();
        next;
    }


    my $http_meth = $openapi->{'_http_method'};
    if (!$http_meth) {
        $openapi->error("HTTP method not detected.");
        $openapi->response();
        next;
    }
    if ($bits[0] eq 'model') {
        my $object = $ModelDispatcher[$#bits];
        my $meth = $http_meth . '_' . $object;
        ### $meth
        if (!$openapi->can($meth)) {
            $object =~ s/_/ /g;
            $openapi->error("HTTP $http_meth method not supported for $object.");
            $openapi->response();
            next;
        }
        my $data;
        eval {
            $openapi->global_model_check(\@bits, $http_meth);
            $data = $openapi->$meth(\@bits);
        };
        if ($@) { $openapi->error($@); }
        else { $openapi->data($data); }
    } elsif ($bits[0] eq 'admin') { # XXX caution!!!
        my $object = $bits[1];
        my $meth = $http_meth . '_admin_' . $object;
        if (!$openapi->can($meth)) {
            $object =~ s/_/ /g;
            $openapi->error("HTTP $http_meth method not supported for '$object'.");
            $openapi->response();
            next;
        }
        my $data;
        eval {
            $data = $openapi->$meth(\@bits);
        };
        if ($@) { $openapi->error($@); }
        else { $openapi->data($data); }
    } elsif ($bits[0] eq 'action') {
        my $object = $bits[1];
        my $meth = $http_meth . '_action_' . $object;
        if (!$openapi->can($meth)) {
            $object =~ s/_/ /g;
            $openapi->error("HTTP $http_meth method not supported for '$object'.");
            $openapi->response();
            next;
        }
        my $data;
        my @params = @bits[2..$#bits];
        eval {
            $data = $openapi->$meth({ @params });
        };
        if ($@) { $openapi->error($@); }
        else { $openapi->data($data); }
    } else {
        $openapi->error("Unknown URL catagory: $bits[0]");
    }

    $openapi->response();
}

