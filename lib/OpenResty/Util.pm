package OpenResty::Util;

use strict;
use warnings;

use OpenResty::Limits;
use base 'Exporter';

our @EXPORT = qw( _IDENT  Q QI check_password slurp );

sub _IDENT {
    (defined $_[0] && $_[0] =~ /^[A-Za-z]\w*$/) ? $_[0] : undef;
}

sub Q (@) {
    if (@_ == 1) {
        return $OpenResty::Backend->quote($_[0]);
    } else {
        return map { $OpenResty::Backend->quote($_) } @_;
    }
}

sub QI (@) {
    if (@_ == 1) {
        return $OpenResty::Backend->quote_identifier($_[0]);
    } else {
        return map { $OpenResty::Backend->quote_identifier($_) } @_;
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

