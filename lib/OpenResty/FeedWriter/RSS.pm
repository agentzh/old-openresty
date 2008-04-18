package OpenResty::FeedWriter::RSS;

use strict;
use warnings;

use Carp qw(croak);
use Params::Util qw(_HASH);

sub new {
    my ($class, $global) = @_;
    _HASH($global) or croak "global settings must be a hash";
    bless {
        global => $global,
    }, $class;
}

sub as_xml {
    my $self = shift;
    my $globals = $self->{global};
    my $s = <<'_EOC_';
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
_EOC_
    for my $key (qw<
            title link description language
            copyright pubDate lastBuildDate
            category >) {
        my $value = delete $globals->{$key};
        next if !defined $value;
        $value =~ s/\&/\&amp;/g;
        $value =~ s/</\&lt;/g;
        $value =~ s/>/\&gt;/g;
        $s .= "    <$key>$value</$key>\n";
    }
    $s .= <<'_EOC_';
  </channel>
</rss>
_EOC_
    return $s;
}

1;

