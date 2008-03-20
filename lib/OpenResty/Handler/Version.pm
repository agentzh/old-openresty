package OpenResty::Handler::Version;

use strict;
use warnings;

use FindBin;
use OpenResty;
use OpenResty::Util;

our $Revision;

sub trim {
    (my $s = $_[0]) =~ s/\s+//gs;
    $s;
}

sub GET_version {
    my ($self, $openresty, $bits) = @_;
    my $s;
    eval {
            $s = slurp("$FindBin::Bin/../revision")
    };
    if ($@) { $Revision = 'Unknown'; }
    else { $Revision ||= trim($s) || 'Unknown'; }
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

