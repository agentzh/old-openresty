package WWW::OpenAPI::Simple;

use strict;
use warnings;

use Carp 'confess';
use JSON::Syck ();
use base 'WWW::OpenAPI';

sub request {
    my $self = shift;
    my $res = $self->SUPER::request(@_);
    if ($res->is_success) {
        my $json = $res->content;
        my $data = JSON::Syck::Load($json);
        return $data;
    }
    confess "$_[2] $_[3]: ", $res->status_line;
}

1;

