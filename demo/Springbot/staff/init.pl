#!/usr/bin/env perl

use strict;
use warnings;

use Params::Util qw(_HASH);
use WWW::OpenResty::Simple;
use JSON::XS;
use Getopt::Std;

my %opts;
getopts('u:p:s:', \%opts) or
    die "Usage: ./init.pl -u <user> -p <password> -s <server>\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";
my $server = $opts{s} or die "No -s specified.\n";

my $resty = WWW::OpenResty::Simple->new(
    { server => $server }
);
$resty->login($user, $password);

if ($resty->has_model('YahooStaff')) {
    $resty->delete('/=/model/YahooStaff');
}

$resty->post(
    '/=/model/YahooStaff',
    {
        description => 'Yahoo! China Staff',
        columns => [
            { name => 'name', label => 'Name', type => 'text' },
            { name => 'name_pinyin', label => 'PinYin for name', type => 'text' },
            { name => 'employee_id', label => 'Employee Identifier', type => 'text' },
            { name => 'department', label => 'Department Name', type => 'text' },
            { name => 'email', label => 'Email address', type => 'text' },
            { name => 'office_phone', label => 'Office phone number', type => 'text' },
            { name => 'cellphone', label => 'Cellphone number', type => 'text' },
            { name => 'yahoo_im_id', label => 'Yahoo! Instant Messager ID', type => 'text' },
            { name => 'position', label => 'Position', type => 'text' },
            { name => 'gender', label => 'Position', type => 'text' },
            { name => 'workplace', label => 'Position', type => 'text' },
        ],
    }
);

my $res = $resty->get('/=/model');
print dumper($res);

sub dumper {
    JSON::XS->new->utf8->pretty->encode($_[0]);
}

