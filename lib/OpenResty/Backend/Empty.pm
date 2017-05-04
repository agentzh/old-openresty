package OpenResty::Backend::Empty;

use strict;
use warnings;

#use Smart::Comments '####';
use base 'OpenResty::Backend::Base';

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub ping {
    1;
}

sub select {
    1;
}

sub do {
    1;
}

sub quote {
    my ($self, $val) = @_;
    if (!defined $val) { return 'NULL' }
    $val =~ s/'/''/g;
    $val =~ s{\\}{\\\\}g;
    "'$val'";
}

sub quote_identifier {
    my ($self, $val) = @_;
    if (!defined $val) { return '""' }
    $val =~ s/"/""/g;
    $val =~ s{\\}{\\\\}g;
    qq{"$val"};
}

sub last_insert_id {
    1;
}


sub has_user {
    1;
}

sub set_user {
    1;
}

sub add_user {
    1;
}

sub add_empty_user {
    1; 
}

sub drop_user {
    1;
}

sub login {
    1;
}

sub get_upgrading_base {
    -1;
}

sub _upgrade_metamodel {
    -1;
}


1;
__END__

=head1 NAME

OpenResty::Backend::PgFarm - OpenResty backend for the PostgreSQL PL/Proxy-based cluster databases

=head1 INHERITANCE

    OpenResty::Backend::PgFarm
        ISA OpenResty::Backend::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PLPerl>, L<OpenResty::Backend::PgMocked>, L<OpenResty>.

