package OpenResty::FastCGI;

our $VERSION = '0.001000';

use FCGI;
use base 'CGI::Simple';

# workaround for known bug in libfcgi
while (($ignore) = each %ENV) { }

# override the initialization behavior so that
# state is NOT maintained between invocations 
sub save_request {
    # no-op
}

# If ENV{FCGI_SOCKET_PATH} is specified, we maintain a FCGI Request handle
# in this package variable.
use vars qw($Ext_Request);
BEGIN {
   # If ENV{FCGI_SOCKET_PATH} is given, explicitly open the socket,
   # and keep the request handle around from which to call Accept().
   if ($ENV{FCGI_SOCKET_PATH}) {
    my $path    = $ENV{FCGI_SOCKET_PATH};
    my $backlog = $ENV{FCGI_LISTEN_QUEUE} || 100;
    my $socket  = FCGI::OpenSocket( $path, $backlog );
    $Ext_Request = FCGI::Request( \*STDIN, \*STDOUT, \*STDERR, 
                    \%ENV, $socket, 1 );
   }
}

# New is slightly different in that it calls FCGI's
# accept() method.
sub new {
     my ($self, $initializer, @param) = @_;
     unless (defined $initializer) {
        if ($Ext_Request) {
            return undef unless $Ext_Request->Accept() >= 0;
        } else {
            return undef unless FCGI::accept() >= 0;
        }
     }
     return $CGI::Q = $self->SUPER::new($initializer, @param);
}

1;

