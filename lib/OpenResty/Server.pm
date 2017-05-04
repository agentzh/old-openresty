package OpenResty::Server;

use strict;
use warnings;
use base qw(HTTP::Server::Simple::CGI);

our $IsRunning = 0;

sub handle_request {
    my ($self, $cgi) = @_;
    $IsRunning = 1;
    OpenResty::Dispatcher->process_request($cgi);
}

#sub net_server { "Net::Server::PreFork" }

1;
__END__

=head1 NAME

OpenResty::Server - Standalone server based on HTTP::Server::Simple for OpenResty

=head1 INHERITANCE

    OpenResty::Server
        ISA HTTP::Server::Simple::CGI

=head1 DESCRIPTION

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>.

=head1 SEE ALSO

L<openresty>, L<HTTP::Server::Simple::CGI>, L<OpenResty>.

