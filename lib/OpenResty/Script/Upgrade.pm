package OpenResty::Script::Upgrade;

use strict;
use warnings;

sub go {
    my ($class, $backend, $user) = @_;
    if ($user) {
        if ($backend->has_user($user)) {
            $backend->set_user($user);
            my $base = $backend->get_upgrading_base;
            if ($base >= 0) {
                $backend->upgrade_local_metamodel($base);
            } else {
                warn "User $user is already up to date.\n";
            }
        } else {
            die "User $user does not exist.\n";
        }
    } else {
        $backend->upgrade_all;
    }
}

1;
