package SQL::Select;

use strict;
use warnings;

sub new {
    my $class = shift;
    bless {
        select => [],
        from => [],
        where => [],
        limit => undef,
        offset => undef,
        order_by => undef,
    }, $class;
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
    my $where = join ' and ', map { join('', @$_) } @where;
    if ($where) { $sql .= "\nwhere $where" }
    my $order_by = $self->{order_by};
    if ($order_by) { $sql .= "\norder by $order_by"; }
    return $sql . ";\n";
}

1;

