#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/../lib";
use OpenResty::Dispatcher;

eval {
    OpenResty::Dispatcher->init();
};
warn $@ if $@;

my $host_suffix = shift || '';

#my $dump_file = 'metamodel.sql';
my $backend = $OpenResty::Backend;
my $backend_name = $OpenResty::BackendName;

my @files = glob 'metamodel/*.sql';
my @accounts;
for my $file (@files) {
    if ($file =~ /(\w+).sql/) {
        push @accounts, $1;
    } else {
        die "Bad SQL file name: $file\n";
    }
}
### @accounts

#my @tables = qw(
#_views _models _columns _feeds _roles _access _general
#);
my $db = $OpenResty::Config{'backend.database'};
my $user = $OpenResty::Config{'backend.user'};
my $password = $OpenResty::Config{'backend.password'};
my $host = 'localhost';

for my $account (@accounts) {
    if (!$backend->has_user($account)) {
        if ($backend_name eq 'Pg') {
            warn "Adding account $account...\n";
            $backend->do("create schema $account;");
        } else {
            die "User $account not found.\n";
        }
    }
    $backend->set_user($account);

    my $machine = $backend->has_user($account);
    if ($backend_name eq 'PgFarm') {
        $db = $machine;
        $host = $machine . $host_suffix;
    }

    my $sql_file = shift @files;
    my $sql = <<'_EOC_';
SELECT
c.relname, c.relkind
FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_roles r ON r.oid = c.relowner
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast')
AND pg_catalog.pg_table_is_visible(c.oid)
AND c.relname ~ '^_'
ORDER BY c.relkind DESC
_EOC_
    my $res;
    eval {
        $res = $backend->select($sql);
    };
    if ($@) { warn $@; }
    #my @rels = map { $_->[0] } @$res;
    ### $res
    for my $rel (@$res) {
        ### $rel
        my ($name, $kind) = @$rel;
        if ($kind eq 'r') {
            eval {
                $backend->do("drop table if exists \"$name\" cascade;");
            };
            if ($@) { warn $@ }
        } elsif ($kind eq 'S') {
            eval {
                $backend->do("drop sequence if exists \"$name\" cascade;");
            };
            if ($@) { warn $@ }
        } elsif ($kind eq 'i') {
            eval {
                $backend->do("drop index if exists \"$name\" cascade;");
            };
            if ($@) { warn $@ }
        } else {
            die "Ignoring database object $name of kind $kind\n";
        }
    }
    warn "Importing metamodel for account $account from $sql_file...\n";
    if (system("psql -U $user -qn -d $db -f $sql_file > /dev/null") != 0) {
        warn "Failed to import metamodel for account $account from $sql_file.\n";
    } #else { warn "Done.\n"; }

    #die;
}

