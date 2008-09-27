#!/usr/bin/env perl

use strict;
use warnings;

use lib '../../lib';
use utf8;
use JSON::XS;
use YAML 'Dump';
use WWW::OpenResty::Simple;
#use Date::Manip;
use Getopt::Std;
use Digest::MD5 'md5_hex';

my %opts;
getopts('u:s:p:h', \%opts);
if ($opts{h}) {
    die "Usage: $0 -u <user> -p <password> -s <openresty_server>\n";
}
my $user = $opts{u} or
    die "No OpenResty account name specified via option -u\n";
my $password = $opts{p} or
    die "No OpenResty account's Admin password specified via option -p\n";
my $server = $opts{s} || 'http://api.openresty.org';

my $resty = WWW::OpenResty::Simple->new( { server => $server } );
$resty->login($user, $password);
$resty->delete("/=/role/Public/~/~");
#$resty->delete("/=/role");
$resty->delete("/=/view");
$resty->delete("/=/feed");
$resty->delete("/=/model");
$resty->delete('/=/role');

$resty->post(
    '/=/model/Menu',
    {
        description => "Site menus",
        columns => [
            { name => 'name', type => 'ltree', label => 'Menu name (anchor)' },
            { name => 'label', type => 'text', label => 'Menu label' },
            { name => 'content', type => 'text', label => 'Menu content' },
            { name => 'display_order', type => 'smallint', label => 'Menu content', default => 0 },
        ],
    }
);

$resty->post(
    '/=/view/MenuList',
    { description => 'Menu list', definition => <<'_EOC_' }
select name, label
from Menu
where name ~ '*{1}'
order by display_order asc, $order_by | id asc
_EOC_
);

$resty->post(
    '/=/view/SubMenuList',
    { description => 'Sub Menu list', definition => <<'_EOC_' }
select name, label
from Menu
where name ~ ($parent || '.*{1}') :: lquery
order by display_order asc, $order_by | id asc
_EOC_
);

$resty->post(
    '/=/role/Public/~/~',
    [
        {url => '/=/model/Menu/~/~'},
        {url => '/=/model/Menu/name/contact', prohibiting => 1},
        {url => '/=/view/MenuList/~/~'},
        {url => '/=/view/SubMenuList/~/~'},
    ]
);

$resty->post(
    '/=/role/nina',
    {
        description => 'nina role',
        login => 'password',
        password => md5_hex('password'),
    }
);

$resty->post(
    '/=/role/nina/~/~',
    [
        {url => '/=/model/Menu/~/~'},
        {url => '/=/view/MenuList/~/~'},
        {url => '/=/view/SubMenuList/~/~'},
    ]
);

print Dump($resty->get('/=/model')), "\n";

