package OpenResty::SQL::Select;

use strict;
use warnings;

#use Smart::Comments '####';
use base 'OpenResty::SQL::Statement';
#use Encode qw( encode is_utf8 decode );

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    bless {
        select => [@_],
        from => [],
        where => [],
        limit => undef,
        offset => undef,
        order_by => [],
        op => 'and',
    }, $class;
}

sub select {
    my $self = shift;
    push @{ $self->{select} }, @_;
    $self;
}

sub from {
    my $self = shift;
    push @{ $self->{from} }, @_;
    $self;
}

sub limit {
    $_[0]->{limit} = $_[1];
    $_[0]
}

sub offset {
    $_[0]->{offset} = $_[1];
    $_[0];
}

sub order_by {
    my $self = shift;
    push @{ $self->{order_by} }, join(" ", @_);
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
    $sql .= "select @{ $self->{select} } from @{ $self->{from} }";
    #### $sql
    my @where = @{ $self->{where} };
    my $where = join(' '.$self->{op}.' ', map { join(' ', @$_) } @where);
    #### $where
    #$where = decode('utf8', $where);
    if ($where) { $sql .= " where $where" }
    #### UTF flag: is_utf8($where)
        #### $sql
    my $order_by = $self->{order_by};
    if (@$order_by) { $sql .= " order by @$order_by"; }
    my $limit = $self->{limit};
    if (defined $limit) { $sql .= " limit $limit"; }
    my $offset = $self->{offset};
    if ($offset) { $sql .= " offset $offset"; }
    ### $sql
    return $sql . ";\n";
}

1;
__END__

=head1 NAME

OpenResty::SQL::Select - SQL generator for select statements

=head1 INHERITANCE

    OpenResty::SQL::Select
        ISA OpenResty::SQL::Statement

=head1 SYNOPSIS

    use OpenResty::SQL::Select;

    my $select = OpenResty::SQL::Select->new;
    $select->select( qw<name type label> )
        ->from( '_columns' );
    $select->where("table_name", '=', _Q('blah'));
    $select->order_by("foo");
    $select->where("Foo", '>', 'bar')->where('Bar' => '3');
    print "$select";
        # produces:
        #       select name, type, label
        #       from _columns
        #       where table_name = 'blah' and Foo > bar and Bar = 3
        #       order by foo;

=head1 DESCRIPTION

This class provides an OO interface for generating SQL select statements without the pain of concatenating plain SQL strings.

=head1 METHODS

=over

=item C<new(@columns)>

=item C<from(@tables)>

=item C<where($column => $value)>

=item C<order_by($column)>
=item C<order_by($column => $direction)>

=item C<limit($limit)>

=item C<offset($offset)>

=item C<generate>

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::SQL::Statement>, L<OpenResty::SQL::Insert>, L<OpenResty::SQL::Update>, L<OpenResty>.

