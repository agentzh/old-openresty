package SQL::Select;

use strict;
use warnings;
use overload '""' => sub { $_[0]->generate };

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    bless {
        select => [@_],
        from => [],
        where => [],
        limit => undef,
        offset => undef,
        order_by => undef,
    }, $class;
}

sub reset {
    my $self = shift;
    %$self = %{ $self->new(@_) };
    $self;
}

sub select {
    my $self = shift;
    push @{ $self->{select} }, @_;
    $self;
}

sub where {
    my $self = shift;
    push @{ $self->{where} }, [@_];
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
    $self->{order_by} = join(" ", @_);
    $self;
}

sub generate {
    my $self = shift;
    my $sql;
    local $" = ',';
    $sql .= "select @{ $self->{select} }
from @{ $self->{from} }";
    my @where = @{ $self->{where} };
    my $where = join ' and ', map { join(' ', @$_) } @where;
    if ($where) { $sql .= "\nwhere $where" }
    my $order_by = $self->{order_by};
    if ($order_by) { $sql .= "\norder by $order_by"; }
    my $limit = $self->{limit};
    if ($limit) { $sql .= "\nlimit $limit"; }
    my $offset = $self->{offset};
    if ($offset) { $sql .= "\noffset $offset"; }
    return $sql . ";\n";
}

1;

