#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Encode qw(decode encode);

use lib 'lib';
use Params::Util qw( _HASH _ARRAY0 );
use YAML::Syck ();
use JSON::Syck ();
use WWW::OpenResty;

$YAML::Syck::ImplicitUnicode = 1;
$JSON::Syck::ImplicitUnicode = 1;

GetOptions(
    'user|u=s' => \(my $user),
    'model=s' => \(my $model),
    'server=s' => \(my $server),
    'password=s' => \(my $password),
) or die "Usage: $0 --user foo.Public --model Book --server 127.0.0.1\n";

$user or die "No user given.\n";
$model or die "No model given.\n";
$server or die "No server given.\n";

my $yaml = do { local $/; <> };
my $data = YAML::Syck::Load($yaml);
_ARRAY0($data) or die "The YAML data is not an array.\n";
my @rows = @$data;

my $offset = 0;
my $count = 1;
my $url = "/=/model/$model/~/~?user=$user";
if ($password) { $url .= "\&password=$password"; }
my $openapi = WWW::OpenResty->new( { server => $server } );
$openapi->delete($url);
my $inserted = 0;
while (1) {
    last if $offset >= $#rows;
    #select(undef, undef, undef, 0.1);
    print STDERR "$offset\t";
    my $url = "$server/=/model/$model/~/~?user=$user\&offset=$offset\&count=$count\&order_by=id:asc";
    if ($password) {
        $url .= '&password=' . $password;
    }
    my $to = $offset + $count - 1;
    my @elems = @rows[$offset..($to > $#rows ? $#rows : $to)];
    #warn "count: ", scalar(@elems), "\n";
    my $json = JSON::Syck::Dump(\@elems);
    $json = encode('UTF-8', $json);
    #warn $json;

    my $res = $openapi->post($json, $url);
    if (!$res->is_success) {
        die "$url: ", $res->status_line, "\n";
    }
    my $res_json = $res->content;
    $res_json or die "No content found in server's response.\n";
    #$res_json = decode('UTF-8', $res_json);
    my $data = JSON::Syck::Load($res_json);
    if (_HASH($data) && !$data->{success} && $data->{error}) {
        warn "Error from the server: $res_json: $json\n";
    } else {
        $inserted++;
    }
} continue { $offset += $count }

warn "For tatal $inserted (", scalar(@rows), ") records inserted.\n";
#print encode('UTF-8', YAML::Syck::Dump(\@rows));

