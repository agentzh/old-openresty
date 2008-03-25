package OpenResty::Shell::History;

use strict;
use warnings;
use YAML::Syck qw(LoadFile DumpFile);

sub new {
    my ($class, $opts) = @_;
    $opts ||= {};
    my $file = $opts->{file} or
        die "No file name given";
    my $term = $opts->{term} or
        die "No Term::ReadLine object given";
    my $count = $opts->{count} || 100;
    my $features = $term->Features;
    my $hist;
    if (-f $file) {
        $hist = LoadFile($file);
        for my $cmd (@$hist) {
            #warn $cmd;
            $term->addhistory($cmd)
                if $cmd && $cmd =~ /\w/ && $features->{autohistory};
        }
    }
    bless {
        hist => $hist || [],
        file => $file,
        features => $features,
        term => $term,
        count => $count,
    }, $class;
}

sub add_history {
    my ($self, $input) = @_;
    return unless $input && $input =~ /\w/;
    my $hist = $self->{hist};
    my $file = $self->{file};
    my $count = $self->{count};
    if (@$hist >= $count) {
        shift @$hist;
    }
    push @$hist, $input;
    my $features = $self->{features};
    $self->{term}->addhistory($input)
        if $features->{autohistory};
    DumpFile($file, $hist);
}

1;
