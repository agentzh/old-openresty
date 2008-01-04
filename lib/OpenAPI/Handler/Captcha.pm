package OpenAPI;

use strict;
use warnings;
use vars qw( $UUID $Cache );

sub GET_captcha_column {
    my ($self, $bits) = @_;
    my $col = $bits->[1];
    if ($col eq 'id') {
        my $id = $UUID->create_str;
        $Cache->set($id => 1);
        return $id;
    } else {
        die "Unknown captcha column: $col\n";
    }
}

sub GET_captcha_value {
    my ($self, $bits) = @_;
    my $col = $bits->[1];
    my $value = $bits->[2];

    my $ext = 'gif';
    if ($value =~ s/\.(gif|jpg|png|jpeg)$//g) {
        $ext = $1;
    }
    if ($col eq 'id') {
        my $id = $value;
        my $solution = $Cache->get($id);
        if (defined $solution) {
            if ($solution eq '1') { # new ID, no solution yet
                $solution = gen_solution();
            }
            $self->{_captcha_data} = gen_image($solution);
        } else {
            die "Invalid captcha ID: $id\n";
        }
    } else {
        die "Unknown captcha column: $col\n";
    }
}

sub gen_solution {
}

sub gen_image {
}

1;

