package OpenResty::Backend::PgMocked;

use strict;
use warnings;

#use utf8;
#use Smart::Comments '#####';
use Clone qw(clone);
use JSON::XS;
use base 'OpenResty::Backend::Pg';
#use Test::LongString;
use Data::Structure::Util qw( _utf8_off _utf8_on );
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
    my @res;
    while (<$in>) {
        chomp;
        ##### read line: $_
        #die "Found null!!!" if /, \)/;
        my $data = $json_xs->decode($_);
        _utf8_off($data);
        ##### DATA: $data
        push @res, $data;
    }
    close $in;
    return \@res;
}

sub ping { 1; }

sub DumpFile {
    my ($file, $data) = @_;
    open my $out, ">$file" or
        die "Can't open $file for writing: $!";

    #### $data
    for my $elem (@$data) {
        _utf8_on($elem);
        my $json = $json_xs->encode($elem);
        _utf8_off($json);
        #$json = Encode::encode('utf8', $json);
        #warn "is utf8: ", utf8::is_utf8($json);
        #warn "JSON: $json";
        print $out $json, "\n";
    }
    close $out;
}

sub start_recording_file {
    my ($class, $file, $dir) = @_;
    if (!-d "$path/$dir") {
        mkdir "$path/$dir";
    }
    $DataFile = "$path/$dir/$file.json";
    if (!-f $DataFile) {
        $Data = {};
    } else {
        $Data = LoadFile($DataFile) || {};
    }
    $Data = $TransList = [];
}

sub record {
    my ($class, $query, $res, $type) = @_;
    $type ||= 'data';
    if (ref $res && ref $res eq 'die') {
        #use Data::Dumper;
        #warn "HERE!!!! \n", Dumper($res), "\n";
        $res = $$res;
        #warn "RES: $res\n";
        $type = 'die';
    }
    ##### $res
    push @$TransList, ["$query", clone($res), $type];
}

sub stop_recording_file {
    ##### Last: $Data->[-1]
    DumpFile($DataFile, $Data);
    undef $Data;
}

# -------------------
# player routines
# -------------------

sub start_playing_file {
    my ($class, $file, $dir) = @_;
    $DataFile = "$path/$dir/$file.json";
    $Data = LoadFile($DataFile) or
        die "No hash found in data file $DataFile.\n";
    $TransList = $Data or
        die "No transaction list found for $file.\n";
}

sub play {
    my ($class, $query) = @_;
    ### playing...
    my $cur = shift @$TransList;
    #warn "SQL: $cur->[0]";
    #if ($cur->[0] =~ /select2/) { warn "!!!!!!!! $cur >>>>$query<<<<<" }
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
    #$query =~ s/, \)/, NULL)/g;
    my $res = $cur->[1];
    if ($cur->[0] ne $query) {
        #is_string($cur->[0], $query);
        die "Unexpected query: ", $OpenResty::Dumper->($query) .
            " (Expecting: ", $OpenResty::Dumper->($cur->[0]), ")\n";
    }
    my $type = $cur->[-1];
    if ($type eq 'die') {
        die $res;
    }

    return $res;
}

sub new {
    my $class = shift;
    ### Creating class: $class
    my $t_file;
    #my $dir = $0;
    if ($0 =~ m{([^/]+)/([^/]+\.t)$}) {
        my $dir = '';
        if ($1 ne 't') { $dir = $1; }
        my $file = $2;
        $class->start_playing_file($file, $dir);
    } else {
        die "The PgMocked backend is for testing only and it can only work when test_suite.use_http is set to 0.\n\tPerhaps you forgot to edit /etc/openresty/site_openresty.conf?\n";
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
    if (!defined $val) { return 'NULL' }
    $val =~ s/'/''/g;
    my $count = ($val =~ s{\\}{\\\\}g);
    if ($count) {
        return "E'$val'";
    } else {
        return "'$val'";
    }
}

sub quote_identifier {
    my ($self, $val) = @_;
    if (!defined $val) { return '""' }
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
__END__

=head1 NAME

OpenResty::Backend::PgMocked - A mocked-up OpenResty backend for the Pg backend

=head1 INHERITANCE

    OpenResty::Backend::PgMocked
        ISA OpenResty::Backend::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Backend::Base>, L<OpenResty::Backend::Pg>, L<OpenResty::Backend::PgFarm>, L<OpenResty>.

