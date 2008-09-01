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

my $backend = $OpenResty::Backend;
my $backend_name = $OpenResty::BackendName;

my @accounts;
eval {
    @accounts = $backend->get_all_accounts;
};
if ($@) { warn $@ }
### @accounts

#my @tables = qw(
#_views _models _columns _feeds _roles _access _general
#);
if ($backend_name eq 'Pg') {
    for my $account ('_global', @accounts) {
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
        $backend->set_user($account);
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
            #die;
        }
    }
    #die;
    if (system("psql -d test -f result.sql") != 0) {
        warn "Failed to import metamodel from result.sql\n";
    }
}

