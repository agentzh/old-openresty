package OpenResty::Backend::PLPerl;

use strict;
use warnings;

use base 'OpenResty::Backend::Pg';
use OpenResty::Limits;

sub new {
    return bless { user => undef }, $_[0];
}

sub select {
    my ($self, $sql, $opts) = @_;
    my $rv = ::spi_exec_query($sql, $MAX_SELECT_LIMIT) or
        return [];
    my $rows = $rv->{rows} || [];
    unless ($opts->{use_hash}) {
        map { $_ = [values %$_] } @$rows;
    }
    return $rows;
}

sub do {
    my ($self, $sql) = @_;
    my $rv = ::spi_exec_query($sql) or return 0;
    return $rv->{processed};
}

sub quote {
    my $val = pop;
    return undef unless defined $val;
    $val =~ s/\\/\\\\/g;
    $val =~ s/'/''/g;
    "'$val'";
}

sub quote_identifier {
    my $val = pop;
    return undef unless defined $val;
    $val =~ s/\\/\\\\/g;
    $val =~ s/"/""/g;
    qq{"$val"};
}

sub ping { 1; }

1;
__END__

=head1 NAME

OpenResty::Backend::PLPerl - Pg backend for OpenResty running via PL/Perl

=head1 INHERITANCE

    OpenResty::Backend::PLPerl
        ISA OpenResty::Backend::Pg

=head1 DESCRIPTION

At the moment this backend is highly experimental and any serious uses are strongly discouraged.

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PgFarm>, L<OpenResty::Backend::PgMocked>, L<OpenResty>.

