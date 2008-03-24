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

