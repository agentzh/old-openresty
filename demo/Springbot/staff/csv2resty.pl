#!/usr/bin/env perl

use strict;
use warnings;

#use Smart::Comments;
use Encode qw(decode encode);
use Params::Util qw(_HASH);
use WWW::OpenResty::Simple;
use Getopt::Std;

my %opts;
getopts('u:p:', \%opts) or
    die "Usage: ./init.pl -u <user> -p <password>\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";


my $resty = WWW::OpenResty::Simple->new(
    { server => 'api.openresty.org' }
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
    my ($name_pinyin, $name, $id, $department, $email, $office_phone, $cellphone, $im_id)
        = @cols;
    my $row = {};
    for my $key (qw< name_pinyin name employee_id department email office_phone cellphone yahoo_im_id>) {
        my $value = shift @cols;
        $row->{$key} = $value;
    }
    push @rows, $row;
    ### $row
    if (@rows % 20 == 0) {
        $inserted += insert_rows(\@rows);
        @rows = ();
        print STDERR "\t$inserted" if $inserted % 20 == 0;
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
    print STDERR "\t$inserted" if $inserted % 20 == 0;
}

