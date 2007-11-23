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
    print "URL: $url\n";
    print "page: ", url_param("page"), "\n";
    print "charset: ", url_param("charset"), "\n";
    my $data;
    print "Content-type: ", content_type(), "\n";
    eval {
        #$data = getRequestBody();
    };
    if ($@) { print $@; }
    print "POSTDATA: $data\n";
    $data = param('POSTDATA');
    print "POSTDATA2: $data\n";
    #print Dumper($query);
    print Dumper(\%ENV);
    my $ext = qr/\.\w+/;
    if ($url =~ m{^/=/model($ext)?$}) {
        my $ext = $1;
        print "Showing model list with ext $ext\n";
    } elsif ($url =~ m{^/=/model/(\w+)($ext)?}) {
        my ($table, $ext) = ($1, $2);
        print "Showing model $table with ext $ext\n";
    }
    if ($url =~ m{^/websearch(\.\w+)?}) {
        my $format = lc($1);
        warn "Format: $format\n";
        my $query = param('q') || 'Perl';
        my $res = $google->scrape( URI->new("http://www.google.cn/search?q=$query") );
        for my $item (@$res) {
            $item->{url} = ''.$item->{url};
        }
        my ($data, $type);
        $type = param('type');
        if ($type eq 'text') { $type = 'text/plain'; }
        if ($format eq '.json' or $format eq '.js') {
            $type ||= 'application/json; charset=utf-8';
            $data = JSON::Syck::Dump($res);
        } elsif ($format eq '.yaml' or $format eq '.yml') {
            $type ||= 'application/yaml; charset=utf-8';
            $data = YAML::Syck::Dump($res);
        } else {
            $type ||= 'text/xml; charset=utf-8';
            my $xs = XML::Simple->new;
            $data = $xs->XMLout($res, KeyAttr => ['results']);
        }
        #print start_html("Fast CGI Rocks");
        if ($type !~ /charset=/i) {
            $type .= '; charset=utf-8';
        }
        #die $type;
        print header(-type => $type), $data;

=start comments

            h1("URL: $url"),
            h1("query: $query"),
            pre($data),
            "Invocation number ",b($COUNTER++),
            " PID ",b($$),".",
            hr;
        print end_html;
=cut

    } else {
        my $file = url(-relative=>1) || $Url;
        $file = File::Spec->catfile($FindBin::Bin, $file);
        #print "X-Sendfile: $file\n";
        print "X-LIGHTTPD-send-file: $file\n";
        #print "\n";
        my $type;
        if ($file =~ /\.js$/) {
            $type = "application/javascript";
        }
        print header(-type => "application/javascript");
        #$file =~ s{^/}{};

=start comment
        if ($file =~ /\.js$/) {
            #warn $file;
            print header(-type => "application/javascript");
            open my $in, $file;
            while (<$in>) {
                print;
            }
            close $file;
        }
=cut

    }
    my $method = $ENV{'REQUEST_METHOD'};
    print $method, "\n";
}

