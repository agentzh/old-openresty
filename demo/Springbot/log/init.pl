#!/usr/bin/env perl

use strict;
use warnings;

use Params::Util qw(_HASH);
use WWW::OpenResty::Simple;
use JSON::XS;
use Getopt::Std;

my %opts;
getopts('u:p:', \%opts) or
    die "Usage: ./init.pl -u <user> -p <password>\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";

my $resty = WWW::OpenResty::Simple->new(
    { server => 'resty.eeeeworks.org' }
);
$resty->login($user, $password);
if (!has_model($resty, 'IrcLog')) {
    $resty->post(
        '/=/model/IrcLog',
        {
            description => 'IRC Log',
            columns => [
                { name => 'sender', label => 'Sender' },
                { name => 'channel', label => 'IRC channel' },
                { name => 'content', label => 'Content' },
                { name => 'type', label => 'Message type (msg or action)' },
                { name => 'sent_on', label => 'Sending time',
                  type => 'timestamp (0) with time zone',
                  default => ['now()'] },
            ],
        }
    );
}

my $res = $resty->get('/=/model');
print dumper($res);

sub dumper {
    JSON::XS->new->utf8->pretty->encode($_[0]);
}

sub has_model {
    my ($resty, $model) = @_;
    eval {
        $resty->get("/=/model/$model");
    };
    if ($@ && $@ =~ /Model .*? not found/i) {
        return undef;
    }
    return 1;
}

