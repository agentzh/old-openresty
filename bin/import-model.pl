#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use lib 'lib';
use Params::Util qw( _HASH );
use JSON::XS ();
use WWW::OpenResty::Simple;

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
_EOC_
}

my $server = 'resty.eeeeworks.org';
my $step = 20;
GetOptions(
    'help|h'   => \(my $help),
    'user|u=s' => \(my $user),
    'model=s' => \(my $model),
    'server=s' => \$server,
    'password=s' => \(my $password),
    'step=i' => \$step,
    'reset' => \(my $reset),
    'retries=i' => \(my $retries),
) or die usage();

if ($help) { print usage() }

$user or die "No --user given.\n";
$model or die "No --model given.\n";

my $json_xs = JSON::XS->new->utf8;

my $openresty = WWW::OpenResty::Simple->new(
    { server => $server, retries => $retries }
);
$openresty->login($user, $password);
if ($reset) { $openresty->delete("/=/model/$model/~/~"); }

my @rows;
my $inserted = 0;
local $| = 1;
while (<>) {
    #select(undef, undef, undef, 0.1);
    #warn "count: ", scalar(@elems), "\n";
    my $row = $json_xs->decode($_);

    push @rows, $row;
    if (@rows % $step == 0) {
        $inserted += insert_rows(\@rows);
        @rows = ();
        print STDERR "\rInserted rows: $inserted";
    }
}

if (@rows) {
    $inserted += insert_rows(\@rows);
}
print STDERR "\n$inserted row(s) inserted.\n";

sub insert_rows {
    my $rows = shift;
    my $res = $openresty->post(
        "/=/model/$model/~/~",
        $rows
    );
    return 0 unless _HASH($res);
    return $res->{rows_affected} || 0;
}

warn "\nFor tatal $inserted records inserted.\n";
#print encode('UTF-8', YAML::Syck::Dump(\@rows));

