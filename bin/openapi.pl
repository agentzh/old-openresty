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
        OpenAPI::Dispatcher->process_request($cgi);
    }
} elsif ($cmd eq 'cgi') {
    require CGI;
    my $cgi = CGI->new;
    OpenAPI::Dispatcher->process_request($cgi);
} elsif ($cmd eq 'perl') {
    require CGI;
    my $server = OpenAPI::Server->new;
    $server->run;
} else {
    die "Unknown command: $cmd";
}

package OpenAPI::Server;
use base qw(HTTP::Server::Simple::CGI);

sub handle_request {
    my ($self, $cgi) = @_;
    OpenAPI::Dispatcher->process_request($cgi);
}

