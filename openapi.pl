#!/usr/bin/env perl
# OpenAPI implementation

use strict;
use warnings;

BEGIN {
    $SIG{__WARN__} = sub { print @_ };
    $SIG{__DIE__} = sub { print @_  };
}

use URI;
use Web::Scraper;
use CGI::Fast qw(:standard);
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper;
use XML::Simple qw(:strict);
use FindBin;
use DBI;

my $dbh = DBI->connect("dbi:Pg:dbname=test", "agentzh", "agentzh", {AutoCommit => 1, RaiseError => 1});

$CGI::POST_MAX = 1024 * 1000;  # max 1000K posts
$CGI::DISABLE_UPLOADS = 1;  # no uploads

my $COUNTER = 0;
while (my $query = new CGI::Fast) {
    my $url  = url(-absolute=>1);
    print header(-type => 'text/plain');
    #print "URL: $url\n";
    #print "page: ", url_param("page"), "\n";
    #print "charset: ", url_param("charset"), "\n";
    my $data;
    #print "Content-type: ", content_type(), "\n";
    eval {
        #$data = getRequestBody();
    };;
    if ($@) { print $@; }
    #print "POSTDATA: $data\n";
    $data = param('POSTDATA');
    #print "POSTDATA2: $data\n";
    #print Dumper($query);
    #print Dumper(\%ENV);
    my $ext = qr/\.\w+/;
    if ($url =~ m{^/=/model($ext)?$}) {
        my $ext = $1;
        print "Showing model list with ext $ext\n";
    } elsif ($url =~ m{^/=/model/(\w+)($ext)?}) {
        my ($table, $ext) = ($1, $2);
        print "Showing model $table with ext $ext\n";
    }
    my $method = $ENV{'REQUEST_METHOD'};
    print $method, "\n";
}

