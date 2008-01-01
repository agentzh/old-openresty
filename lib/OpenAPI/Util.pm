package OpenAPI;

use strict;
use warnings;
use vars qw($Backend);

sub Q (@) {
    if (@_ == 1) {
        return $Backend->quote($_[0]);
    } else {
        return map { $Backend->quote($_) } @_;
    }
}

sub QI (@) {
    if (@_ == 1) {
        return $Backend->quote_identifier($_[0]);
    } else {
        return map { $Backend->quote_identifier($_) } @_;
    }
}

1;

