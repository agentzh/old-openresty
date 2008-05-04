#!/usr/bin/env perl

use strict;
use warnings;
use Encode qw(from_to);

my $html = do { local $/; <> };
from_to($html, 'gbk', 'utf8');
$html =~ s/\&nbsp;/ /gs;
$html =~ s/\&lt;/</gs;
$html =~ s/\&gt;/>/gs;
$html =~ s/\&amp;/\&/gs;
$html =~ s{\s+}{ }gs;
$html =~ s{</td>}{|}gsi;
$html =~ s{</tr>}{\n}sgi;
$html =~ s{</?[^>]+>}{}sg;
$html =~ s{<!--[.\n]*?-->}{}sg;
$html =~ s/ +//g;
print $html;

