#!/usr/bin/env perl

use strict;
use warnings;

use Params::Util qw(_HASH);
use WWW::OpenResty::Simple '0.04';
use JSON::XS;
use Getopt::Std;

my %opts;
getopts('u:p:', \%opts) or
    die "Usage: ./init.pl -u <user> -p <password>\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";

my $resty = WWW::OpenResty::Simple->new(
    { server => 'api.openresty.org' }
);
$resty->login($user, $password);
if (!$resty->has_model('IrcLog')) {
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

eval { $resty->delete('/=/view/LastSeen'); };
if (!$resty->has_view('LastSeen')) {
    warn "Creating view...\n";
    $resty->post(
        '/=/view/LastSeen',
        {
            description => 'A person last seen on a channel',
            definition => q{select * from IrcLog
                where sender = $sender
                order by sent_on desc
                limit 1
            },
        }
    );

}

my $res = $resty->get('/=/model');
print dumper($res);

$res = $resty->get('/=/view/LastSeen');
print dumper($res);

sub dumper {
    JSON::XS->new->utf8->pretty->encode($_[0]);
}

