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
        my $dns = $OpenAPI::Backend::PgFarm::DNS;
        if ($dns =~ /host=([^=\s;]+)/) {
            $dns = $1;
            if ($dns =~ /[-\w]+/) {
                $dns = $&;
            }
        }
        $backend .= " ($dns)";
    }
    return "OpenAPI $VERSION (revision $Revision) with the $backend backend.\nCopyright (c) 2007-2008 Yahoo! China EEEE\n";
}

1;

