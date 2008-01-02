#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/../lib";
use OpenAPI::Dispatcher;
use OpenAPI::Limits;

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
    exit;
} elsif ($cmd eq 'cgi') {
    require CGI;
    my $cgi = CGI->new;
    OpenAPI::Dispatcher->process_request($cgi);
    exit;
} elsif ($cmd eq 'start') {
    require OpenAPI::Server;
    my $server = OpenAPI::Server->new;
    #$server->port(8000);
    $server->run;
    exit;
}

my $error = $OpenAPI::Dispatcher::DBFatal;
if ($error) {
    die $error;
}
my $backend = $OpenAPI::Backend;

if ($cmd eq 'adduser') {
    my $user = shift or
        die "No user specified.\n";
    if ($backend->has_user($user)) {
        die "User $user already exists.\n";
    }
    eval "use Term::ReadKey;";
    if ($@) { die $@; }
    local $| = 1;

    my $password;
    print "Enter the password for the Admin role: ";
    ReadMode(2);
    my $key;
    while (not defined ($key = ReadLine(0))) {
    }
    $key =~ s/\n//s;
    print "\n";

    my $saved_key = $key;
    #warn "Password: $password\n";
    OpenAPI::check_password($saved_key);

    print "Re Enter the password for the Admin role: ";
    while (not defined ($key = ReadLine(0))) {
    }
    $key =~ s/\n//s;
    print "\n";

    if ($key ne $saved_key) {
        die "2 passwords don't match.\n";
    }
    $password = $key;

    $OpenAPI::Backend->add_user($user, $password);
} elsif ($cmd eq 'deluser') {
    my $user = shift or
        die "No user specified.\n";
    if ($backend->has_user($user)) {
        $OpenAPI::Backend->drop_user($user);
    } else {
        die "User $user does not exist.\n";
    }
} else {
    die "Unknown command: $cmd\n";
}



