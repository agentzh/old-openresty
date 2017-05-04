package OpenResty::Backend;

#use Smart::Comments;
use strict;
use warnings;

sub new {
    my ($class, $backend) = @_;
    if (!$backend) {
        die "No backend specified";
    }
    my $backend_class = $class . '::' . $backend;
    ### $backend_class
    eval "use $backend_class";
    if ($@) {
        die $@;
    }
    $backend_class->new({ PrintWarn => 0 });
}

1;
__END__

=head1 NAME

OpenResty::Backend - class factory for OpenResty backend classes

=head1 SYNOPSIS

    my $type = 'Pg'; # or 'PgFarm' or 'PgMocked'
    my $backend = OpenResty::Backend->new($type);
        # where $backend is a OpenResty::Backend::Pg instance.

=head1 DESCRIPTION

This class serves as a class factory for the various OpenResty backend classes like L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PgFarm>, and L<OpenResty::Backend::PgMocked>.

=head1 METHODS

=over

=item C<< $obj = OpenResty::Backend->new($type) >>

Creates an instance of the specified backend class (via C<$type>).

=back

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PgMocked>, L<OpenResty::Backend::Pg>, L<OpenResty>.

