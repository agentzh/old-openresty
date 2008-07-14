package OpenResty::Server;

use strict;
use warnings;
use base qw(HTTP::Server::Simple::CGI);

sub handle_request {
    my ($self, $cgi) = @_;
    OpenResty::Dispatcher->process_request($cgi);
}

1;
__END__

=head1 NAME

OpenResty::Server - Standalone server based on HTTP::Server::Simple for OpenResty

=head1 INHERITANCE

    OpenResty::Server
        ISA HTTP::Server::Simple::CGI

=head1 DESCRIPTION

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>.

=head1 SEE ALSO

L<openresty>, L<HTTP::Server::Simple::CGI>, L<OpenResty>.

