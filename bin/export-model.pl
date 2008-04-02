#!/usr/bin/env perl

# Sample:
# bin/export-model.pl --user carrie --model YisouComments \
#  --server http://resty.eeeeworks.org \
#  > YisouComments.yml

use strict;
use warnings;

use Getopt::Long;
use Encode qw(decode encode);

use lib 'lib';
use WWW::OpenResty::Simple;
use Params::Util qw( _HASH _ARRAY0 );
use JSON::XS ();

my $step = 500;
my $server = 'resty.eeeeworks.org';
GetOptions(
    'user|u=s' => \(my $user),
    'model=s' => \(my $model),
    'server=s' => \$server,
    'password=s' => \(my $password),
    'step=i' => \$step,
    'out=s' => \(my $outfile),
    'retries=i' => \(my $retries),
) or die "Usage: $0 --user foo.Public --model Book --server 127.0.0.1\n";

$user or die "No user given.\n";
$model or die "No model given.\n";

my $out;
if ($outfile) {
    open $out, ">$outfile" or
        die "Can't open $outfile for writing: $!\n";
} else {
    $out = \*STDOUT;
}

my $resty = WWW::OpenResty::Simple->new(
    { server => $server, retries => $retries }
);
$resty->login($user, $password);

my $json_xs = JSON::XS->new->utf8;

my $offset = 0;
my $exported = 0;
while (1) {
    my $url = "/=/model/$model/~/~";
    my %args = (
        offset => $offset,
        count => $step,
        order_by => "id:asc",
    );
    my $res = $resty->get($url, \%args);
    if (_ARRAY0($res)) {
        for my $row (@$res) {
            print $out $json_xs->encode($row), "\n";
        }
        $exported += @$res;
        print STDERR "\rExported rows: $exported";
        last if @$res < $step;
    }
} continue { $offset += $step }
close $out;

warn "\nFor tatal $exported record(s) obtained.\n";

