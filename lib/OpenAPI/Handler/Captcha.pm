package OpenAPI;

use Smart::Comments;
use strict;
use warnings;

use vars qw( $UUID $Cache );
use GD::SecurityImage;
use utf8;
use Encode 'encode';

our $Captcha;

# Create a normal image
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
        if ($ext eq 'jpg') { $ext = 'jpeg' }
    }
    if ($col eq 'id') {
        my $id = $value;
        my $solution = $Cache->get($id);
        if (defined $solution) {
            if ($solution eq '1') { # new ID, no solution yet
                $solution = $self->gen_solution();
            }
            $self->gen_image($ext, $solution);
            return;
        } else {
            die "Invalid captcha ID: $id\n";
        }
    } else {
        die "Unknown captcha column: $col\n";
    }
}

sub gen_solution {
    my ($self) = @_;
    "1234";
}

sub gen_image {
    my ($self, $type, $str) = @_;
    $Captcha = GD::SecurityImage->new(
        width   => 150,
        height  => 100,
        lines   => 12,
        font    => "/usr/share/fonts/simkai.ttf",
        thickness => 0.2,
        rndmax => 1,
        angle => 23 - (int rand 46),
        #send_ctobg => 1,
        #scramble => 1,
    );

    my $str = '一心一意';
    $Captcha->random($str);
    $Captcha->create(ttf => 'default');
    $Captcha->particle(1732);
    my ($image_data, $mime_type) = $Captcha->out();
    $self->{_bin_data} = $image_data;
    $self->{_type} = "image/$mime_type";
    ### $mime_type
}

1;

