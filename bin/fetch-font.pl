#!/usr/bin/env perl

use strict;
use warnings;

use LWP::UserAgent;

my $url = 'http://agentzh.org/misc/wqy-zenhei.ttf';
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

mkdir 'font' unless -d 'font';
my $file = 'share/font/wqy-zenhei.ttf';
unless (-f $file and -s $file > 13000000) {
    warn "Fetching $url...\n";
    $ua->mirror($url, $file);
}

