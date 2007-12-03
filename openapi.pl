#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin";
use OpenAPI;
#use Web::Scraper;
use CGI::Fast ();
use Data::Dumper;
#use XML::Simple qw(:strict);
use FindBin;
use DBI;
use Smart::Comments;
#use Perl6::Say;

$CGI::POST_MAX = 1024 * 1000;  # max 1000K posts
#$CGI::DISABLE_UPLOADS = 1;  # no uploads
my $DBFatal;

# XXX Excpetion not caputred...when database 'test' not created.
eval {
    OpenAPI->connect();
};
if ($@) {
    $DBFatal = $@;
}

my @ModelDispatcher = qw(
    model_list model model_column model_row
);

my $ext = qr/\.(?:js|json|xml|yaml|yml)/;
while (my $cgi = new CGI::Fast) {
    my $url  = $cgi->url(-absolute=>1);
    $url =~ s{^/+}{}g;
    #print header(-type => 'text/plain; charset=UTF-8');

    my $openapi;
    eval {
        $openapi = OpenAPI->new(\$url, $cgi);
        if ($DBFatal) {
            $openapi->error($DBFatal);
            $openapi->response();
            next;
        }
    };
    if ($@) {
        print OpenAPI->emit_error($@), "\n";
        next;
    }

    #$url =~ s/\/+$//g;
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";

    my @bits = split /\//, $url, 5;
    if (!@bits) {
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

    # XXX this part is lame...
    my $user = 'tester';
    eval {
        #OpenAPI->drop_user($user);
    };
    if ($@) { warn $@; }
    if (my $retval = OpenAPI->has_user($user)) {
        ### Found user: $user
    } else {
        ### Creating new user: $user
        OpenAPI->new_user($user);
    };
    eval {
        OpenAPI->do("set search_path to $user");
    };
    if ($@) { print OpenAPI->emit_error($@), "\n"; next; }

    my $http_meth = $openapi->{_method};
    if ($bits[0] =~ /^model\b/i) {
        my $meth = $http_meth . '_' . $ModelDispatcher[$#bits];
        ### $meth
        my $data;
        eval { $data = $openapi->$meth(\@bits); };
        if ($@) { $openapi->error($@); }
        else { $openapi->data($data); }
    }

    $openapi->response();
}

