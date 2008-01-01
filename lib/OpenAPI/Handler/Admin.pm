package OpenAPI;

use strict;
use warnings;
use vars qw($Dumper);

sub POST_admin_op {
    my ($self, $bits) = @_;
    my $op = $bits->[1];
    if ($op ne 'select' and $op ne 'do') {
        die "Admin operation not supported: $op\n";
    }
    ### $op
    my $sql = _STRING($self->{_req_data}) or
        die "SQL literal must be a string.\n";

    if ($op eq 'select') {
        return $self->select($sql, { use_hash => 1 });
    } elsif ($op eq 'do') {
        $self->do($sql);
        return { success => 1 };
    }
}

1;

