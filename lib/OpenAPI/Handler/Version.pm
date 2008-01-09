package OpenAPI;

use strict;
use warnings;

use FindBin;
use OpenAPI;

use vars qw($VERSION $Revision);

sub GET_version {
    my ($self, $bits) = @_;
    $Revision ||= slurp("$FindBin::Bin/../revision") || 'Unknown';
    return "OpenAPI 1.0.0 (revision $Revision)\nCopyright (c) 2007-2008 Yahoo! China EEEE\n";
}

1;

