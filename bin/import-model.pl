#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use lib 'lib';
use Params::Util qw( _HASH );
use JSON::XS ();
use WWW::OpenResty::Simple;
use Data::Dumper;

sub usage {
    my $progname;
    if ($0 =~ m{[^/\\]+$}) {
        $progname = $&;
    }
    return <<_EOC_;
Usage: $progname [options] <json_file>
Options:
    --user <user>      OpenResty user (i.e. agentzh.Admin)
    --password <s>     OpenResty password for the user specified
    --model <model>    OpenResty model name being imported
    --server <host>    OpenResty server hostname
    --step <num>       Size of the bulk insertion group
    --retries <num>    Number of automatic retries when failures occur
    --no-id            Skipped the id field in the records being imported
    --skip N           Skipped the first N rows in the input file (default 0)
    --add-id N          Add ID started from N (default 1)
_EOC_
}

my $server = 'api.openresty.org';
my $step = 20;
my $skip = 0;
my $add_id = 1;
GetOptions(
    'help|h'   => \(my $help),
    'user|u=s' => \(my $user),
    'model=s' => \(my $model),
    'server=s' => \$server,
    'password=s' => \(my $password),
    'step=i' => \$step,
    'reset' => \(my $reset),
    'retries=i' => \(my $retries),
    'no-id' => \(my $no_id),
    'skip=i' => \$skip,
    'add-id=i' => \$add_id,
    'ignore-dup-error' => \(my $ignore_dup_error),
) or die usage();

if ($help) { print usage() }

$user or die "No --user given.\n";
$model or die "No --model given.\n";

my $json_xs = JSON::XS->new->utf8->allow_nonref;

my $openresty = WWW::OpenResty::Simple->new(
    { server => $server, retries => $retries, ignore_dup_error => $ignore_dup_error }
);
$openresty->login($user, $password);
if ($reset) { $openresty->delete("/=/model/$model/~/~"); }

my @rows;
my $inserted = 0;
local $| = 1;
while (<>) {
    #select(undef, undef, undef, 0.1);
    #warn "count: ", scalar(@elems), "\n";
    next if $. <= $skip;
    my $row = $json_xs->decode($_);

    if (!defined $row->{id}) {
        #warn "ADDing id...\n";
        $row->{id} = $add_id++;
    }
    if ($no_id) {
        delete $row->{id};
    }
    push @rows, $row;
    if (@rows % $step == 0) {
        $inserted += insert_rows(\@rows);
        @rows = ();
        print STDERR "\rInserted rows: $inserted (row $.)";
    }
}

if (@rows) {
    $inserted += insert_rows(\@rows);
}
print STDERR "\n$inserted row(s) inserted.\n";

sub insert_rows {
    my $rows = shift;
    my $res;
    eval {
        $res = $openresty->post(
            "/=/model/$model/~/~",
            $rows
        );
    };
    if ($@ || !_HASH($res)) {
        die "Around line $.: $@", (defined $res ? $json_xs->encode($res) : $res);
        return 0;
    }
    #warn Dumper($res);
    return $res->{rows_affected} || 0;
}

warn "\nFor tatal $inserted records inserted.\n";
#print encode('UTF-8', YAML::Syck::Dump(\@rows));

