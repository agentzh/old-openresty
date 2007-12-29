package OpenAPI::Server;

use strict;
use warnings;
use base qw(HTTP::Server::Simple::CGI);

sub handle_request {
    my ($self, $cgi) = @_;
    OpenAPI::Dispatcher->process_request($cgi);
}

1;

