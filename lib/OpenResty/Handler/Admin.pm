package OpenResty::Handler::Admin;

use strict;
use warnings;

use Params::Util qw( _STRING );

sub POST_admin_op {
    my ($self, $openresty, $bits) = @_;
    my $op = $bits->[1];
    if ($op ne 'select' and $op ne 'do') {
        die "Admin operation not supported: $op\n";
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

Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::Handler::Model>, L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

