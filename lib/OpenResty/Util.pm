package OpenResty::Util;

use strict;
use warnings;

use CGI::Simple ();
use Class::Prototyped;

use OpenResty::Limits;
use Data::Structure::Util qw(_utf8_off);

use base 'Exporter';

our @EXPORT = qw( _IDENT Q QI check_password slurp url_encode new_mocked_cgi );

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
    #if ($password !~ /^[_A-Za-z0-9]+$/) {
    #die "Invalid password; only underscores, letters, and digits are allowed.\n";
    #}
}

sub slurp {
    my ($file) = @_;
    open my $in, $file or die "Can't oepn $file for reading: $!\n";
    my $s = do { local $/; <$in> };
    close $in;
    $s;
}

sub url_encode {
    my $s = shift;
    _utf8_off($s);
    $s =~ s/[^\w\-\.\@]/sprintf("%%%2.2x",ord($&))/eg;
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
        remote_host => sub {
            return '127.0.0.1';
        },
    );
}

1;
__END__

=head1 NAME

OpenResty::Util - Utility functions for OpenResty

=head1 DESCRIPTION

This module exports a set of utility functions used for other OpenResty server components.

=head1 FUNCTIONS

This module exports the following functions by default:

=over

=item C<$value = _IDENT($value)>

Validates if C<$value> is an well-formed identifier in OpenResty's sense. Essentially it's specified by the following Perl regex:

    /^[A-Za-z]\w*$/

C<_IDENT> returns the input argument if it's well-formed; undef otherwise.

=item C<$quoted = Q($value)>

Quotes the value as if it's a SQL value literal. Basically, C<foo's bar> will become C<'foo''s bar'>.

=item C<$quoted = QI($value)>

Quotes the value as if it's a SQL identifier literal. Basically, C<foo> will become C<"foo">.

=item C<$bool = check_password($password)>

Checks whether the given password (C<$password>) is well-formed. 1 if true, undef otherwise.

=item C<$content = slurp($filename)>

Returns all the content of the file specified by C<$filename>.

=item C<$cgi = new_mocked_cgi($url, $content)>

Returns a mocked-up CGI object from URL (specified by C<$url>) and the HTTP request content (specified by C<$content>).

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>.

=head1 SEE ALSO

L<OpenResty>.

