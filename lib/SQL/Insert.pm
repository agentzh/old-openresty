package SQL::Insert;

use strict;
use warnings;
use base 'SQL::Statement';

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
    push @{ $self->{cols} }, $_[0];
    $self;
}

sub values {
    my $self = shift;
    push @{ $self->{values} }, $_[0];
    $self;
}

sub generate {
    my $self = shift;
    my $sql;
    local $" = ', ';
    $sql .= "insert into $self->{table}";
    my $cols = $self->{cols};
    if ($cols) {
        $sql .= " (@$cols)";
    }
    $sql .= " (@{ $self->{values} })";
    return $sql . ";\n";
}

1;

