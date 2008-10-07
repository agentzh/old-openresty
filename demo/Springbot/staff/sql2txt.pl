#!/usr/bin/env perl

use strict;
use warnings;

use encoding 'utf8';
use JSON::Syck qw(Dump);
use Encode qw(decode encode);
use Smart::Comments;

print "姓名|工号|部门|邮箱|分机号|手机|雅虎通|职位|性别|工作地|\n";
while (<>) {
    if (s/^INSERT INTO `rolldata` VALUES //) {
        #$_ = dtf8', $_);
        #warn "Found!";
        my @rows = split /\),\(/, $_;
        #warn scalar(@rows);
        $rows[0] =~ s/^\(//;
        $rows[-1] =~ s/\)$//;
        for my $row (@rows) {
            my @vals = split /','/, $row;
            $vals[0] =~ s/^'//;
            $vals[-1] =~ s/'$//;
            #print "<<<< $row >>>>\n";
            #warn Dump(\@vals), "\n";
            my ($email, $name, $emp_id, $depart, $pos, $sex, $place) = @vals;
            my $yid = $vals[14];
            my $phone = $vals[15];
            my $cell= $vals[16];
            $pos =~ s/高级|资深|首席//g;
            $pos = '' if $pos eq '总监';
            print "$name|$emp_id|$depart|$email|$phone|$cell|$yid|$pos|$sex|$place|\n";
        }
    }
}

