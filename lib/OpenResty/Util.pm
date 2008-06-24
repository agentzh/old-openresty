package OpenResty::Util;

use strict;
use warnings;

use CGI::Simple ();
use Class::Prototyped;

use OpenResty::Limits;
use base 'Exporter';

our @EXPORT = qw( _IDENT Q QI check_password slurp new_mocked_cgi );

my $Cgi = CGI::Simple->new;

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

sub new_mocked_cgi {
    my ($uri, $content) = @_;
    $uri =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    my %url_params;
    if ($uri =~ /\?(.+)/) {
        my $list = $1;
        my @params = split /\&/, $list;
        for my $param (@params) {
            my ($var, $val) = split /=/, $param, 2;
            $url_params{$var} = $val;
        }
    }
    my $cgi = Class::Prototyped->new(
        param => sub {
            my ($self, $key) = @_;
            #warn "!!!!!$key!!!!";
            if ($key =~ /^(?:PUTDATA|POSTDATA)$/) {
                my $s = $content;
                if (!defined $s or $s eq '') {
                    return undef;
                }
                return $s;
            }
            $url_params{$key};
        },
        url_param => sub {
            my ($self, $name) = @_;
            #warn ">>>>>>>>>>>>>>> url_param: $name\n";
            if (defined $name) {
                return $url_params{$name};
            } else {
                return keys %url_params;
            }
        },
        header => sub {
            my $self = shift;
            return $Cgi->header(@_);
        },
    );
}

1;

