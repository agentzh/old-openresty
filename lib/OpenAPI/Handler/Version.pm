package OpenAPI;

use strict;
use warnings;

use FindBin;
use OpenAPI;

use vars qw($VERSION $Revision);

sub GET_version {
    my ($self, $bits) = @_;
    $Revision ||= slurp("$FindBin::Bin/../revision") || 'Unknown';
    my $backend = $OpenAPI::BackendName;
    if ($backend eq 'PgFarm') {
        my $dns = $OpenAPI::Backend::PgFarm::DNS;
        if ($dns =~ /host=([^=\s]+)/) {
            $dns = $1;
        }
        $backend .= " ($1)";
    }
    return "OpenAPI $VERSION (revision $Revision) with the $backend backend.\nCopyright (c) 2007-2008 Yahoo! China EEEE\n";
}

1;

