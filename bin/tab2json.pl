use strict;
use warnings;

use utf8;
use JSON::XS;

my $json_xs = JSON::XS->new->utf8;

my @files = map glob, @ARGV;
if (!@files) { die "No input file given.\n"; }

for my $file (@files) {
    my $outfile = $file;
    if ($outfile !~ s/\.txt$/.json/) {
        $outfile .= '.json';
    }
    process_file($file, $outfile);
}

sub process_file {
    my ($infile, $outfile) = @_;
    open my $out, $outfile or
        die "Cannot open output file $outfile for writing: $!\n";
    open my $in, $infile or
        die "Cannot open input file $infile for reading: $!\n";
    my $first = <$in>;
    my @fields = split_by_tab $first;
    while (<$in>) {
        my @vals = split_by_tab $_;
        my %data;
        for my $i (0..$#fields) {
            $data{$fields[$i]} = $vals[$i];
        }
        print $out $json_xs->encode(\%data), "\n";
    }
    close $in;
    close $out;
}

sub split_by_tab {
    my ($line, $tab) = @_;
    my @vals;
    while (1) {
        if ($line =~ /\G([^\t]*)\t/gc) {
            push @vals, $1;
        } elsif ($line =~ /\G[^\t]+$/) {
            push @vals, $&;
            last;
        } else {
            push @vals, undef;
        }
    }
    #map { $_ ? $_ : undef } @vals;
}

