package OpenResty;

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

sub check_password {
    my $password = shift;
    if (!defined $password) {
        die "No password specified.\n";
    }
    if (length($password) < $PASSWORD_MIN_LEN) {
        die "Password too short; at least $PASSWORD_MIN_LEN chars are required.\n";
    }
    if ($password !~ /^[_A-Za-z0-9]+$/) {
        die "Invalid password; only underscores, letters, and digits are allowed.\n";
    }
}

sub slurp {
    my ($file) = @_;
    open my $in, $file or die "Can't oepn $file for reading: $!\n";
    my $s = do { local $/; <$in> };
    close $in;
    $s;
}

1;

