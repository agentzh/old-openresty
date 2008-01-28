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
    $Revision ||= trim(slurp("$FindBin::Bin/../revision")) || 'Unknown';
    my $backend = $OpenAPI::BackendName;
    if ($backend eq 'PgFarm') {
        my $host = $OpenAPI::Backend::PgFarm::Host;
        if ($host =~ /[-\w]+/) {
            $host = $&;
        }
        $backend .= " ($host)";
    }
    return "Yahoo! EEEE OpenAPI $VERSION (revision $Revision) with the $backend backend.\nCopyright (c) 2007-2008 by Yahoo! China EEEE works.\n";
}

1;

