#!/usr/bin/env perl
# OpenAPI implementation

use strict;
use warnings;

use URI;
use Web::Scraper;
use CGI::Fast qw(:standard);
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper;
use XML::Simple qw(:strict);
use FindBin;

=begin comment
sub getRequestBody() {
    my ($in);
    binmode STDIN;
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'}) ||
        die "Can't read from STDIN: $!\n";
    return $in;
}
=end comment
=cut

$CGI::POST_MAX=1024 * 100;  # max 100K posts
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
    };
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

