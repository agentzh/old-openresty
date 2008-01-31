package WWW::OpenAPI::Simple;

use strict;
use warnings;

#use Carp 'confess';
use JSON::Syck ();
use base 'WWW::OpenAPI';
use Params::Util qw( _HASH );

sub request {
    my $self = shift;
    my $data = $_[0];
    my $meth = $_[1];
    my $url = $_[2];
    if ($data && ref $data) {
        $_[0] = JSON::Syck::Dump($data);
    }
    my $res = $self->SUPER::request(@_);
    if ($res->is_success) {
        my $json = $res->content;
        my $data = JSON::Syck::Load($json);
        if (_HASH($data) && defined $data->{success} && $data->{success} == 0) {
            die "$meth $url: $json\n";
        }
        return $data;
    }
    die "$meth $url: ", $res->status_line, "\n";
}

1;

