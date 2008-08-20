package OpenResty::QuasiQuote::SQL;

use strict;
use warnings;

require Filter::QuasiQuote;
our @ISA = qw( Filter::QuasiQuote );

sub sql {
    my ($self, $s, $file, $line, $col) = @_;
    my $package = ref $self;
    #warn "SQL: $file: $line: $s\n";
    $s =~ s/^\s+|\s+$/ /gs;
    #$s =~ s/\n/ /gs;
    $s =~ s/\\/\\\\/g;
    $s =~ s/\s+/ /gs;
    #$s =~ s/\t/\\t/gs;
    $s =~ s/"/\\"/g;
    $s =~ s/\$(\w+)\b([^:])/".Q(\$$1)."$2/g;
    $s =~ s/\$\w+$/".Q($&)."/g;
    $s =~ s/\$sym:(\w+)\b/".QI(\$$1)."/g;
    $s =~ s/\$kw:(\w+)\b/".\$$1."/g;
    if ($s =~ /\$(\w+):\w+\b/) {
        die __PACKAGE__, ": Unknown antiquoting sequence: $&\n";
    }
    $s = qq{"$s"};
    $s =~ s/\.""$//;
    $s;
}

1;

