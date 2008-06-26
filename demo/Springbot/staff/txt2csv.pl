#!/usr/bin/env perl

use strict;
use warnings;

use Text::CSV;
use Encode qw(encode decode);

my %PinYin;
my $pinyin_file = 'PinYin.csv';
open my $fh, $pinyin_file or
    die "Can't open $pinyin_file for reading: $!\n";
while (<$fh>) {
    my ($han, $pinyin) = split /,/, $_;
    $pinyin =~ s/\W//g;
    $han = decode('utf8', $han);
    next if $PinYin{$han};
    $PinYin{$han} = $pinyin;
}
close $fh;

sub to_pinyin {
    my $s = shift;
    $s = decode('utf8', $s);
    my $o;
    for my $h (split //, $s) {
        #die $h;
        $o .= $PinYin{$h} || '';
    }
    $o;
}

my $csv = Text::CSV->new({binary => 1});
while (<>) {
    s/\s*\|\s*$/\n/g;
    my @cols = split /\|/;
    my $count = grep { $_ } @cols;
    next if !$cols[0] or !$cols[1] or $count < 4;
    my $name = $cols[0];
    my $pinyin = to_pinyin($name);
    $pinyin =~ s/zhangpojue/zhangxiaojue/;
    unshift @cols, $pinyin;
    print join(",", @cols);
}

