#!/usr/bin/env perl

use strict;
use warnings;

my $html = do { local $/; <> };
$html =~ s/\&nbsp;/ /gs;
$html =~ s{\s+}{ }gs;
$html =~ s{</td>}{|}gsi;
$html =~ s{</tr>}{\n}sgi;
$html =~ s{</?[^>]+>}{}sg;
$html =~ s{<!--[.\n]*?-->}{}sg;
$html =~ s/ +//g;
print $html;

