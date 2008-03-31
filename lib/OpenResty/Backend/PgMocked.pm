package OpenResty::Backend::PgMocked;

use strict;
use warnings;

#use Smart::Comments;
use JSON::XS;
use base 'OpenResty::Backend::Pg';
use Test::LongString;
#use Encode qw(is_utf8 encode decode);

our ($DataFile, $Data, $TransList);

#$JSON::Syck::SortKeys = 1;

# -------------------
# Recorder routines
# -------------------

my $path = 't/pgmock-data';
unless (-d $path) { mkdir $path }

my $json_xs = JSON::XS->new->utf8->allow_nonref;

sub LoadFile {
    my ($file) = @_;
    open my $in, $file or
        die "Can't open $file for reading: $!";
    my $json = do { local $/; <$in> };
    close $in;
    $json_xs->decode($json);
}

sub ping { 1; }

sub DumpFile {
    my ($file, $data) = @_;
    open my $out, ">$file" or
        die "Can't open $file for writing: $!";

    my $json = $json_xs->encode($data);
    #print $out encode('utf8', $json);
    print $out $json;
    close $out;
}

sub start_recording_file {
    my $class = shift;
    my $file = shift;
    $DataFile = "$path/$file.json";
    if (!-f $DataFile) {
        $Data = {};
    } else {
        $Data = LoadFile($DataFile) || {};
    }
    $Data = $TransList = [];
}

sub record {
    my ($class, $query, $res) = @_;
    push @$TransList, ["$query", $res];
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
    $DataFile = "$path/$file.json";
    $Data = LoadFile($DataFile) or
        die "No hash found in data file $DataFile.\n";
    $TransList = $Data or
        die "No transaction list found for $file.\n";
}

sub play {
    my ($class, $query) = @_;
    ### playing...
    my $cur = shift @$TransList;
    if (!$cur) {
        die "No more expected response for query $query";
    }
    #if (is_utf8($query)) {
        #$query = encode('utf8', $query);
    #}
    #if (is_utf8($cur->[0])) {
    #$cur->[0] = encode('utf8', $cur->[0]);
    #}
    #$query =~ s/'3\.14159'/'3.14158999999999988'/;
    #$query =~ s/'3\.14'/'3.14000000000000012'/;
    $query =~ s/'3\.1415[89]{4,}\d*'/'3.14159'/;
    $query =~ s/'3\.140{4,}\d*'/'3.14'/;
    if ($cur->[0] ne $query) {
        #is_string($cur->[0], $query);
        die "Unexpected query: ", $OpenResty::Dumper->($query) .
            " (Expecting: ", $OpenResty::Dumper->($cur->[0]), ")\n";
    }
    return $cur->[1];
}

sub new {
    my $class = shift;
    ### Creating class: $class
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
    if (!defined $val) { return undef }
    $val =~ s/'/''/g;
    $val =~ s{\\}{\\\\}g;
    "'$val'";
}

sub quote_identifier {
    my ($self, $val) = @_;
    if (!defined $val) { return undef }
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

