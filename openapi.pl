#!/usr/bin/env perl
# OpenAPI implementation

use strict;
use warnings;
#use subs 'warn';

use FindBin;
#$SIG{__WARN__} = sub { print @_; };
#$SIG{__DIE__} = sub { print @_;  };

use lib "$FindBin::Bin";
use OpenAPI;
use URI;
use Web::Scraper;
use CGI::Fast qw(:standard);
use YAML::Syck ();
use JSON::Syck ();
use Data::Dumper;
use XML::Simple qw(:strict);
use FindBin;
use DBI;
use Smart::Comments;


$CGI::POST_MAX = 1024 * 1000;  # max 1000K posts
$CGI::DISABLE_UPLOADS = 1;  # no uploads
our $LastError;

eval {
    OpenAPI->connect();
};
if ($@) {
    $LastError = $@;
}

my $ext = qr/\.\w+/;
my $COUNTER = 0;
while (my $query = new CGI::Fast) {
    my $url  = url(-absolute=>1);
    print header(-type => 'text/plain');
    #print "URL: $url\n";
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";
    if ($LastError) {
        print $LastError;
    }
    my $data;
    ### Content-type: content_type()
    my $user = 'test';
    #OpenAPI->drop_user($user);
    if (my $retval = OpenAPI->has_user($user)) {
        ### Found user: $user
        ### Retval: $retval
    } else {
        ### Creating new user: $user
        OpenAPI->new_user($user);
    };
    OpenAPI->do("SET search_path TO $user");
    #print "POSTDATA: $data\n";
    my $method = $ENV{'REQUEST_METHOD'};
    print $method, "\n";
    if ($method eq 'GET') {
        ### GET method detected: $url
        if ($url =~ m{^/=/model($ext)?$}) {
            my $ext = $1;
            ### Showing model list with ext: $ext
        } elsif ($url =~ m{^/=/model/(\w+)($ext)?}) {
            my ($table, $ext) = ($1, $2);
            ### Showing model $table with ext: $ext
        }
    } elsif ($method eq 'DELETE') {
        ### DELETE method detected: $url
        if ($url =~ m{^/=/model($ext)?$}) {
            ### Deleting all the models...
            my $tables = OpenAPI->get_tables($user);
            if ($tables && @$tables) {
                ### tables: @$tables
                for my $table (@$tables) {
                    OpenAPI->drop_table($user, $table);
                }
            }
        }
    } elsif ($method eq 'POST') {
        ### POST method detected: $url
        # check for content-type...
        $data = param('POSTDATA');
        ### POST data: $data
    } elsif ($method eq 'PUT') {
        ### PUT method detected: $url
    }
    #print Dumper($query);
    #print Dumper(\%ENV);
}

