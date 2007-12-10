package SQL::Update;

use strict;
use warnings;
use base 'SQL::Statement';

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

sub generate {
    my $self = shift;
    my $sql;
    local $" = ',';
    $sql .= "update $self->{update}
set @{ $self->{set} }";
    my @where = @{ $self->{where} };
    my $where = join ' and ', map { join(' ', @$_) } @where;
    if ($where) { $sql .= "\nwhere $where" }
    return $sql . ";\n";
}

1;

