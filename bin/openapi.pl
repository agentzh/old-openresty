#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/../lib";
use CGI::Fast ();
use OpenAPI::Dispatcher;

OpenAPI::Dispatcher->init;

while (my $cgi = new CGI::Fast) {
    OpenAPI::Dispatcher->process_request($cgi);
}

