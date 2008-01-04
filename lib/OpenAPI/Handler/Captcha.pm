package OpenAPI;

use Smart::Comments;
use strict;
use warnings;

use vars qw( $UUID $Cache );
use GD::SecurityImage;
use utf8;
use Encode 'encode';

our $Captcha;
my @WordList = qw(
    word hello world moon machine teatcher school
    book cookie howdy greeting data tree table
    print company friend girl character
    water beef meat meet heavy student
    worker labor money 
);

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
    my $str;
    for (1..2) {
        my $i = int rand scalar(@WordList);
        $str .= " ". $WordList[$i];
    }
    $str;
}

sub gen_image {
    my ($self, $type, $str) = @_;
    $Captcha = GD::SecurityImage->new(
        width   => 180,
        height  => 30,
        lines   => 1,
        font    => "$FindBin::Bin/../StayPuft.ttf",
        #thickness => 0.9,
        rndmax => 4,
        angle => 23 - (int rand 46),
        ptsize => 80,
        #send_ctobg => 1,
        #scramble => 1,
    );

    $Captcha->random($str);
    $Captcha->create(normal => 'rect');
    $Captcha->particle(432);
    my ($image_data, $mime_type) = $Captcha->out();
    $self->{_bin_data} = $image_data;
    $self->{_type} = "image/$mime_type";
    ### $mime_type
}

1;

