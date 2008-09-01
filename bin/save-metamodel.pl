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

my $dump_file = 'metamodel.sql';
my $backend = $OpenResty::Backend;
my $backend_name = $OpenResty::BackendName;

my @accounts = $backend->get_all_accounts;
### @accounts

#my @tables = qw(
#_views _models _columns _feeds _roles _access _general
#);
if ($backend_name eq 'Pg') {
    system("mv $dump_file $dump_file.old");
    my $db = $OpenResty::Config{'backend.database'};
    my $user = $OpenResty::Config{'backend.user'};
    my $password = $OpenResty::Config{'backend.password'};

    for my $account ('_global', @accounts) {
        warn "Dumping account $account...\n";
        my $sql = <<'_EOC_';
SELECT
  c.relname
FROM pg_catalog.pg_class c
     JOIN pg_catalog.pg_roles r ON r.oid = c.relowner
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
      AND n.nspname NOT IN ('pg_catalog', 'pg_toast')
  AND pg_catalog.pg_table_is_visible(c.oid)
  AND c.relname ~ '^_'
_EOC_
        $backend->set_user($account);
        my $res;
        eval {
            $res = $backend->select($sql);
        };
        if ($@) { warn $@; next }
        my @tables = map { $_->[0] } @$res;
        ### @tables
        #else {dump_res($res);
        my $tables = join ' ', map { "-t '$account.$_'" } @tables;
        my $cmd = "pg_dump -U $user -x $tables -f tmp.sql $db";
        #warn $cmd;
        if (system($cmd) != 0) {
            warn "Failed to dump metamodel from $account\n";
        }
        system("cat tmp.sql >> $dump_file");
    }
}

