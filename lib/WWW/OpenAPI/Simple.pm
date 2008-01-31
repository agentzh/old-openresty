package WWW::OpenAPI::Simple;

use strict;
use warnings;

#use Carp 'confess';
use JSON::Syck ();
use base 'WWW::OpenAPI';
use Params::Util qw( _HASH );

sub request {
    my $self = shift;
    my $meth = $_[1];
    my $url = $_[2];
    my $res = $self->SUPER::request(@_);
    if ($res->is_success) {
        my $json = $res->content;
        my $data = JSON::Syck::Load($json);
        if (_HASH($data) && !$data->{success}) {
            die "$meth $url: $json";
        }
        return $data;
    }
    die "$meth $url: ", $res->status_line;
}

1;

