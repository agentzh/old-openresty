#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/../lib";
use OpenAPI::Dispatcher;

my $cmd = lc(shift) || $ENV{OPENAPI_COMMAND} || 'fastcgi';

OpenAPI::Dispatcher->init;

if ($cmd eq 'fastcgi') {
    require CGI::Fast;
    while (my $cgi = new CGI::Fast) {
        eval {
            OpenAPI::Dispatcher->process_request($cgi);
        };
        if ($@) {
            warn $@;
            print "HTTP/1.1 200 OK\n";
            # XXX don't show $@ to the end user...
            print qq[{"success":0,"error":"$@"}\n];
        }
    }
} elsif ($cmd eq 'cgi') {
    require CGI;
    my $cgi = CGI->new;
    OpenAPI::Dispatcher->process_request($cgi);
} elsif ($cmd eq 'start') {
    require OpenAPI::Server;
    my $server = OpenAPI::Server->new;
    #$server->port(8000);
    $server->run;
} else {
    die "Unknown command: $cmd\n";
}

