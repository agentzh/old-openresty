use strict;
use warnings;

#use utf8;
use Getopt::Long;

my $charset = 'utf8';
GetOptions('charset=s', \$charset) or
    die "Usage: $0 --charset=utf8 *.txt\n";

#use Encode qw(decode encode);
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

sub split_by_tab ($);

sub process_file {
    my ($infile, $outfile) = @_;
    open my $out, ">$outfile" or
        die "Cannot open output file $outfile for writing: $!\n";
    open my $in, "<:$charset", $infile or
        die "Cannot open input file $infile for reading: $!\n";
    my $first = <$in>;
    $first =~ s/[\n\r]+$//g;
    my @fields = split_by_tab $first;
    while (<$in>) {
        s/[\n\r]+$//g;
        my @vals = split_by_tab $_;
        my %data;
        for my $i (0..$#fields) {
            $data{$fields[$i]} = $vals[$i];
        }
        print $out $json_xs->encode(\%data), "\n";
    }
    close $in;
    close $out;
    warn "$outfile generated.\n";
}

sub split_by_tab ($) {
    my ($line) = @_;
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
    @vals
    #map { $_ ? $_ : undef } @vals;
}

