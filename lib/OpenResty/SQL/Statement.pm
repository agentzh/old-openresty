package OpenResty::SQL::Statement;

use strict;
use warnings;
use base 'Clone';
use overload '""' => sub { $_[0]->generate };

sub reset {
    my $self = shift;
    %$self = %{ $self->new(@_) };
    $self;
}

sub where {
    my $self = shift;
    if (@_ == 2) {
        push @{ $self->{where} }, [$_[0], '=', $_[1]];
    } else {
        push @{ $self->{where} }, [@_];
    }
    $self;
}

1;
__END__

=head1 NAME

OpenResty::SQL::Statement - Base class for the various SQL generator classes

=head1 DESCRIPTION

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::SQL::Select>, L<OpenResty::SQL::Insert>, L<OpenResty::SQL::Update>, L<OpenResty>.

