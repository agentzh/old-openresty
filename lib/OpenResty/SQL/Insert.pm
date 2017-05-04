package OpenResty::SQL::Insert;

use strict;
use warnings;
use base 'OpenResty::SQL::Statement';

use overload '""' => sub { $_[0]->generate };

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    bless {
        table => $_[0],
        values => [],
        cols => [],
    }, $class;
}

sub insert {
    $_[0]->{table} = $_[1];
    $_[0]
}

sub cols {
    my $self = shift;
    push @{ $self->{cols} }, @_;
    $self;
}

sub values {
    my $self = shift;
    push @{ $self->{values} }, map { defined $_ ? $_ : 'NULL' } @_;
    $self;
}

sub generate {
    my $self = shift;
    my $sql;
    local $" = ', ';
    $sql .= "insert into $self->{table}";
    my $cols = $self->{cols};
    if ($cols and @$cols) {
        $sql .= " (@$cols)";
    }
    $sql .= " values (@{ $self->{values} })";
    return $sql . ";\n";
}

1;
__END__

=head1 NAME

OpenResty::SQL::Insert - SQL generator for insert statements

=head1 INHERITANCE

    OpenResty::SQL::Insert
        ISA OpenResty::SQL::Statement

=head1 SYNOPSIS

    use OpenResty::SQL::Insert;

    my $insert = OpenResty::SQL::Insert->new;
    $insert->insert( 'models' )
        ->values( 'abc' => '"howdy"' );
    print "$insert";
        # produces: insert into models values (abc, "howdy");

    $insert->cols('foo', 'bar');
    print $insert->generate;
        # produces: insert into models (foo, bar) values (abc, "howdy");

=head1 DESCRIPTION

This class provides an OO interface for generating SQL insert statements without the pain of concatenating plain SQL strings.

=head1 METHODS

=over

=item C<new($table)>

=item C<values(@values)>

=item C<col(@column_names)>

=back

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::SQL::Statement>, L<OpenResty::SQL::Select>, L<OpenResty::SQL::Update>, L<OpenResty>.

