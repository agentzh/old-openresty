#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use Encode qw(decode encode);
use Params::Util qw(_HASH);
use WWW::OpenResty::Simple;
use Getopt::Std;

my %opts;
getopts('u:p:s:', \%opts) or
    die "Usage: ./csv2resty.pl -u <user> -p <password> -s <server>\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";
my $server = $opts{s} or die "No -s specified.\n";

my $resty = WWW::OpenResty::Simple->new(
    { server => $server }
);
$resty->login($user, $password);

$resty->delete('/=/model/YahooStaff/~/~');

my $inserted = 0;
my @rows;
while (<>) {
    $_ = decode('utf8', $_);
    next if $. == 1;
    chomp;
    my @cols = split /,/;
    my ($name_pinyin, $name, $id, $department, $email, $office_phone, $cellphone, $im_id, $pos, $sex, $place, $order_id)
        = @cols;
    my $row = {};
    for my $key (qw< name_pinyin name employee_id department email office_phone cellphone yahoo_im_id position gender workplace order_id>) {
        my $value = shift @cols;
        $row->{$key} = $value;
    }
    if ($order_id !~ /^\d+$/) {
        warn $_;
    } else {
        push @rows, $row;
    }
    ### $row
    if (@rows % 10 == 0) {
        $inserted += insert_rows(\@rows);
        @rows = ();
        print STDERR "\t$inserted " if $inserted % 10 == 0;
    }
}
if (@rows) {
    $inserted += insert_rows(\@rows);
}
print "\n$inserted row(s) inserted.\n";

sub insert_rows {
    my $rows = shift;
    my $res = $resty->post('/=/model/YahooStaff/~/~', $rows);
    return 0 unless _HASH($res);
    return $res->{rows_affected} || 0;
    print STDERR "\t$inserted " if $inserted % 10 == 0;
}

