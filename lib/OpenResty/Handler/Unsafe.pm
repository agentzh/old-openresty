package OpenResty::Handler::Unsafe;

use strict;
use warnings;

use Params::Util qw( _STRING );

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('unsafe');

sub level2name {
    qw< unsafe unsafe_op >[$_[-1]];
}

# XXX TODO we should provide a config option to turn off or on the Unsafe API
sub POST_unsafe_op {
    my ($self, $openresty, $bits) = @_;

    my $user = $openresty->current_user;
    unless ($OpenResty::UnsafeAccounts{$user}) {
        die "Unsafe operations not permitted for the $user account.\n";
    }
    my $op = $bits->[1];
    if ($op ne 'select' and $op ne 'do') {
        die "Unsafe operation not supported: $op\n";
    }
    ### $op
    my $sql = _STRING($openresty->{_req_data}) or
        die "SQL literal must be a string.\n";


    if ($op eq 'select') {
        return $openresty->select($sql, { use_hash => 1 });
    } elsif ($op eq 'do') {
        $openresty->do($sql);
        return { success => 1 };
    }
}

1;
__END__

=head1 NAME

OpenResty::Handler::Unsafe - The "unsafe" handler for OpenResty

=head1 SYNOPSIS

=head1 DESCRIPTION

This OpenResty handler class implements the Unsafe API, i.e., the C</=/unsafe/*> stuff.

=head1 METHODS

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Handler::Model>, L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

