package OpenResty::SQL::Update;

use strict;
use warnings;
use base 'OpenResty::SQL::Statement';

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    bless {
        update => $_[0],
        set => [],
        where => []
    }, $class;
}

sub update {
    $_[0]->{update} = $_[1];
    $_[0]
}
sub set {
    my $self = shift;
    push @{ $self->{set} }, "$_[0] = $_[1]";
    $self;
}

sub op {
    $_[0]->{op} = lc($_[1]);
    $_[0];
}

sub generate {
    my $self = shift;
    my $sql;
    local $" = ', ';
    $sql .= "update $self->{update}
set @{ $self->{set} }";
    my @where = @{ $self->{where} };
    my $op = $self->{op} || 'and';
    my $where = join ' '.$op.' ', map { join(' ', @$_) } @where;
    if ($where) { $sql .= "\nwhere $where" }
    return $sql . ";\n";
}

1;
__END__

=head1 NAME

OpenResty::SQL::Update - SQL generator for update statements

=head1 INHERITANCE

    OpenResty::SQL::Update
        ISA OpenResty::SQL::Statement

=head1 SYNOPSIS

    use OpenResty::SQL::Update;
    my $update = OpenResty::SQL::Update->new;
    $update->update( 'models' )
        ->set( 'abc' => '"howdy"' );
    print $update->generate;
        # produces:
        #      update models set abc = "howdy";

    $update->where("table_name", '=', _Q('blah'))->set(foo => 'bar');
    print "$update";
        # produces:
        #       update models
        #       set abc = "howdy", foo = bar
        #       where table_name = 'blah';

    $update->where("Foo", '>', 'bar');
    print "$update";
        # produces:
        #        update models
        #        set abc = "howdy", foo = bar
        #        where table_name = 'blah' and Foo > bar;

    $update->reset( qw<abc> )
        ->set( 'foo' => 3 )->where(name => '"John"');
    print "$update";
        # produces:
        #       update abc
        #       set foo = 3
        #       where name = "John";

=head1 DESCRIPTION

This class provides an OO interface for generating SQL update statements without the pain of concatenating plain SQL strings.

=head1 METHODS

=over

=item C<new($table)>

=item C<new()>

=item C<update($table)>

=item C<< where($column => $value) >>

=item C<reset()>

=item C<reset($table)>

=item C<generate>

=back

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::SQL::Statement>, L<OpenResty::SQL::Insert>, L<OpenResty::SQL::Select>, L<OpenResty>.

