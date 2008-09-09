package OpenResty::Handler::Version;

use strict;
use warnings;

use FindBin;
use OpenResty;
use OpenResty::Util;
use File::Spec;
use File::ShareDir qw( module_dir );

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('version');

sub requires_acl { undef }

sub level2name {
    qw< version version_verbose >[$_[-1]]
}

our $Revision;

sub trim {
    (my $s = $_[0]) =~ s/\s+//gs;
    $s;
}

sub GET_version { OpenResty->version }

sub GET_version_verbose {
    my ($self, $openresty, $bits) = @_;
    if (!defined $Revision) {
        my $path = "$FindBin::Bin/../share/openresty_revision";
        unless (-f $path) {
            $path = File::Spec->catfile(module_dir('OpenResty'), 'openresty_revision');
        }
        my $s;
        eval {
            $s = slurp($path);
        };
        if ($@) { $Revision = 'Unknown'; }
        else { $Revision ||= trim($s) || 'Unknown'; }
    }
    my $backend = $OpenResty::BackendName;
    if ($backend eq 'PgFarm') {
        my $host = $OpenResty::Backend::PgFarm::Host;
        if ($host =~ /[-\w]+/) {
            $host = $&;
        }
        $backend .= " ($host)";
    }
    my $ver = OpenResty->version;
    return "OpenResty $ver (revision $Revision) with the $backend backend.\nCopyright (c) 2007-2008 by Yahoo! China EEEE Works, Alibaba Inc.\n";
}

1;
__END__

=head1 NAME

OpenResty::Handler::Version - The version handler for OpenResty

=head1 SYNOPSIS

    use OpenResty::Handler::Version;

    $data = OpenResty::Handler::Version->GET_version($openresty, \@url_bits);

=head1 DESCRIPTION

This OpenResty handler class implements the Version API, i.e., the C</=/version> interface.

Typically it returns something like this

"OpenResty 0.3.9 (revision 1682) with the PgFarm (op901000) backend.\nCopyright (c) 2007-2008 by Yahoo! China EEEE Works, Alibaba Inc.\n"

=head1 METHODS

=over

=item C<< $data = OpenResty::Handler::Version->GET_version($openresty, \@url_bits) >>

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Model>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

