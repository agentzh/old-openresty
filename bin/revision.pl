#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);

$ENV{LANG}="C";
$ENV{LC_ALL}="C";

my $revision = 0;
my $base = shift || "$Bin/../";
chdir $base;
my $svn_entries = "$base/.svn/entries";

if (-d '.svn' and my @svn_info = qx/svn info/ and $? == 0) {
    print "Geting version from `svn info`\n";
    if (my ($line) = grep /^Revision:/, @svn_info) {
        ($revision) = $line =~ / (\d+)$/;
    }
}
elsif (-r $svn_entries) {
    print "Getting version from $svn_entries\n";
    open FH, $svn_entries or die "Unable to open file ($svn_entries). Aborting. Error returned was: $!";
    while (<FH>) {
        /^ *committed-rev=.(\d+)./ or next;
        $revision = $1;
        last;
    }
    close FH;
}
elsif (my @svk_info = qx/svk info/ and $? == 0) {
    print "Getting version from `svk info`\n";
    if (my ($line) = grep /(?:file|svn|https?)\b/, @svk_info) {
        ($revision) = $line =~ / (\d+)$/;
    } elsif (my ($source_line) = grep /^(Copied|Merged) From/, @svk_info) {
        if (my ($source_depot) = $source_line =~ /From: (.*?), Rev\. \d+/) {
            if (my ($path_line) = grep /^Depot Path/, @svk_info ) {
                if (my ($depot_path) = $path_line =~ m!Path: (/[^/]*)! ) {
                    $source_depot = "$depot_path$source_depot";
                }
            }
            if (my @svk_info = qx/svk info $source_depot/ and $? == 0) {
                if (my ($line) = grep /(?:file|svn|https?)\b/, @svk_info) {
                    ($revision) = $line =~ / (\d+)$/;
                }
            }
        }
    }
}
$revision ||= 0;

if ($revision == 0) {
    die "Revision failed to obtain.\n";
} else {
    print "Current version is $revision\n";

    my $rev_file = "$FindBin::Bin/../revision";
    print "Updating $rev_file...\n";
    open my $out, ">$rev_file" or
        die "Can't open $rev_file for writing: $!\n";
    print $out $revision;
    close $out;
}

