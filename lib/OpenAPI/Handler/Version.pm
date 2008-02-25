package OpenAPI;

use strict;
use warnings;

use FindBin;
use OpenAPI;

use vars qw($VERSION $Revision);

sub trim {
    (my $s = $_[0]) =~ s/\s+//gs;
    $s;
}

sub GET_version {
    my ($self, $bits) = @_;
    my $s;
    eval {
            $s = slurp("$FindBin::Bin/../revision")
    };
    if ($@) { $Revision = 'Unknown'; }
    else { $Revision ||= trim($s) || 'Unknown'; }
    my $backend = $OpenAPI::BackendName;
    if ($backend eq 'PgFarm') {
        my $host = $OpenAPI::Backend::PgFarm::Host;
        if ($host =~ /[-\w]+/) {
            $host = $&;
        }
        $backend .= " ($host)";
    }
    return "EEEE OpenAPI $VERSION (revision $Revision) with the $backend backend.\nCopyright (c) 2007-2008 by Yahoo! China EEEE Works.\n";
}

1;

