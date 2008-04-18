package OpenResty::FeedWriter::RSS;

use strict;
use warnings;

#use Smart::Comments;
use Carp qw(croak);
use Params::Util qw(_HASH);

sub new {
    my ($class, $global) = @_;
    ### $global
    _HASH($global) or croak "global settings must be a hash";
    bless {
        global => $global,
        entries => [],
    }, $class;
}

sub add_entry {
    my ($self, $entry) = @_;
    my $s;
    for my $key (qw<
            title link description author
            comments pubDate category >) {
        my $value = delete $entry->{$key};
        next if !defined $value;
        _escape($value);
        $s .= "    <$key>$value</$key>\n";
    }
    if (%$entry) {
        croak "Unknown keys: ", join(', ', keys %$entry);
    }
    ### $s
    push @{ $self->{entries} }, "  <item>\n$s  </item>\n";
}

sub as_xml {
    my $self = shift;
    my $global = $self->{global};
    my $s = <<'_EOC_';
<?xml version="1.0"?>
<rss version="2.0">
  <channel>
_EOC_
    for my $key (qw<
            title link description language
            copyright pubDate lastBuildDate
            category >) {
        my $value = delete $global->{$key};
        next if !defined $value;
        _escape($value);
        $s .= "  <$key>$value</$key>\n";
    }
    if (%$global) {
        croak "Unknown keys: ", join(', ', keys %$global);
    }

    my $entries = $self->{entries};
    if (!@$entries) {
        croak "No entries found";
    }
    $s .= join "", @$entries;

    ### $entries
    $s .= <<'_EOC_';
  </channel>
</rss>
_EOC_
    return $s;
}

sub _escape {
    $_[0] =~ s/\&/\&amp;/g;
    $_[0] =~ s/</\&lt;/g;
    $_[0] =~ s/>/\&gt;/g;
}

1;

