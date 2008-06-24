package OpenResty::Inlined;

use strict;
use warnings;

use base 'OpenResty';

sub response {
    my $self = shift;
    if ($self->{_no_response}) { return undef; }

    #print "HTTP/1.1 200 OK\n";
    #warn $s;
    if (my $bin_data = $self->{_bin_data}) {
        return "BINARY DATA";
    }
    if (my $error = $self->{_error}) {
        return $self->emit_error($error);
    }
    if (my $data = $self->{_data}) {
        if ($self->{_warning}) {
            $data->{warning} = $self->{_warning};
        }
        return $data;
    }
    return undef;
}

sub emit_data {
    my ($self, $data) = @_;
    #warn "$data";
    return $data;
}

1;
__END__

=head1 NAME

OpenResty::Inlined - OpenResty app class for inlined REST requrests

