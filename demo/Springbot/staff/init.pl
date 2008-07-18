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
    { server => 'api.openresty.org' }
);
$resty->login($user, $password);
if (!has_model($resty, 'YahooStaff')) {
    $resty->post(
        '/=/model/YahooStaff',
        {
            description => 'Yahoo! China Staff',
            columns => [
                { name => 'name', label => 'Name' },
                { name => 'name_pinyin', label => 'PinYin for name' },
                { name => 'employee_id', label => 'Employee Identifier' },
                { name => 'department', label => 'Department Name' },
                { name => 'email', label => 'Email address' },
                { name => 'office_phone', label => 'Office phone number' },
                { name => 'cellphone', label => 'Cellphone number' },
                { name => 'yahoo_im_id', label => 'Yahoo! Instant Messager ID' },
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

