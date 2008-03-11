package OpenResty::Backend::PgMocked;

use strict;
use warnings;

use JSON::Syck ();
use base 'OpenResty::Backend::Pg';
use Test::LongString;
use Encode qw(is_utf8 encode decode);

our ($DataFile, $Data, $TransList);
$DataFile = 't/pgmocked-data.yml';

$JSON::Syck::ImplicitUnicode = 1;
#$JSON::Syck::SortKeys = 1;

# -------------------
# Recorder routines
# -------------------

sub LoadFile {
    my ($file) = @_;
    open my $in, $file or
        die "Can't open $file for reading: $!";
    my $json = do { local $/; <$in> };
    close $in;
    *JSON::Syck::LoadCode = \&JSON::Syck::LoadCode;
    JSON::Syck::Load($json);
}

sub DumpFile {
    my ($file, $data) = @_;
    open my $out, "> $file" or
        die "Can't open $file for writing: $!";
    *JSON::Syck::UseCode = \&JSON::Syck::UseCode;
    my $json = JSON::Syck::Dump($data);
    print $out encode('utf8', $json);
    close $out;
}

sub start_recording_file {
    my $class = shift;
    if (!$Data) {
        my $file = shift;
        if (!-f $DataFile) {
            $Data = {};
        } else {
            $Data = LoadFile($DataFile) || {};
        }
        $Data->{$file} = ($TransList = []);
    }
}

sub record {
    my ($class, $query, $res) = @_;
    push @$TransList, [$query, $res];
}

sub stop_recording_file {
    DumpFile($DataFile, $Data);
    undef $Data;
}

# -------------------
# player routines
# -------------------

sub start_playing_file {
    my ($class, $file) = @_;
    $Data = LoadFile($DataFile) or
        die "No hash found in yml file $DataFile.\n";
    $TransList = $Data->{$file} or
        die "No transaction list found for $file.\n";
}

sub play {
    my ($class, $query) = @_;
    my $cur = shift @$TransList;
    if (!$cur) {
        die "No more expected response for query $query";
    }
    unless (is_utf8($query)) {
        $query = decode('utf8', $query);
    }
    if ($cur->[0] ne $query) {
        #is_string($cur->[0], $query);
        die "Unexpected query: ", $OpenResty::Dumper->($query) .
            " (Expecting: ", $OpenResty::Dumper->($cur->[0]), ")\n";
    }
    return $cur->[1];
}

sub new {
    my $class = shift;
    my $t_file;
    if ($0 =~ m{[^/]+\.t$}) {
        $t_file = $&;
        $class->start_playing_file($t_file);
    } else {
        die "The PgMocked backend can only work when test_suite.use_http is set to true.\n";
    }
    return bless {}, $class;
}

sub select {
    my $class = shift;
    $class->play(@_);
}

sub do {
    my $class = shift;
    $class->play(@_);
}

sub state {
    '';
}

sub quote {
    my ($self, $val) = @_;
    $val =~ s/'/''/g;
    $val =~ s{\\}{\\\\}g;
    "'$val'";
}

sub quote_identifier {
    my ($self, $val) = @_;
    $val =~ s/"/""/g;
    $val =~ s{\\}{\\\\}g;
    qq{"$val"};
}

sub add_user {
    1;
}

sub drop_user {
    1;
}

1;

