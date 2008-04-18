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
    _HASH($entry) or croak "entry settings must be a hash";
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
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
_EOC_
    for my $key (qw<
            title link description language
            copyright generator pubDate lastBuildDate
            category image >) {
        my $value = delete $global->{$key};
        next if !defined $value;
        if ($key eq 'image') {
            _HASH($value) or croak "Value for the 'image' key should be a non-empty hash";
            $s .= "  <image>\n";
            for my $subkey (qw< url link title >) {
                my $subval = delete $value->{$subkey};
                _escape($subval);
                $s .= "    <$subkey>$subval</$subkey>\n";
            }
            if (%$value) {
                croak "Unexpcted keys in the image hash: " . join (", ", keys %$value);
            }
            $s .= "  </image>\n";
        } else {
            _escape($value);
            $s .= "  <$key>$value</$key>\n";
        }
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

