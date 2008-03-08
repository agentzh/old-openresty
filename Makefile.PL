use strict;
use lib '.';
use inc::Module::Install;

name                ('OpenResty');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenResty.pm');

my $arg = 'devel';
if (@ARGV && $ARGV[0] ne 'releng' && $ARGV[0] =~ /^\w+$/) {
    $arg = shift;
}

my $version = version();
$version .= 0 until length($version) >= length('0.123456');
$version =~ s{^(\d+)\.(\d{3})(\d{3})?$}{join '.', int($1), int($2), int($3||0)}e;
version($version);

requires            ('Cookie::XS' => '0.06');
requires            ('FCGI');
requires            ('CGI::Simple' => '1.103');
requires            ('CGI::Simple::Cookie');
requires            ('YAML::Syck' => '1.04');
requires            ('List::Util');
requires            ('DBI' => '1.57');
requires            ('Clone' => '0.22');
requires            ('Params::Util' => '0.22');
requires            ('Parse::Yapp');
requires            ('DBD::Pg' => '1.49');
requires            ('Data::UUID' => '1.148');
requires            ('GD::SecurityImage' => '1.64');
requires            ('Cache::Memcached::Fast' => '0.06');
requires            ('Hash::Merge');
requires            ('Config::Simple');
requires            ('Encode::Guess');

if ($arg eq 'product') {
    features(
        'Test suite' => [
            -default => 0,
                recommends    ('Term::ReadKey' => '2.30'),
                recommends    ('CGI' => '3.33'),
                recommends    ('Cache::Cache' => '1.05'),
                recommends    ('Smart::Comments'),
                recommends    ('Class::Prototyped'),
                recommends    ('Test::LongString'),
                recommends    ('LWP::UserAgent'),
                recommends    ('HTTP::Response' => '1.53'),
                recommends    ('Benchmark::Timer'),
                recommends    ('HTTP::Server::Simple' => '0.27'),
                recommends    ('WWW::OpenResty' => '0.01'),
                recommends    ('Text::Diff'),
        ]
    );
} elsif ($arg eq 'devel') {
    build_requires      ('CGI' => '3.33');
    build_requires      ('Class::Prototyped');
    build_requires      ('Test::LongString');
    build_requires      ('Text::Diff');
    build_requires      ('LWP::UserAgent');
    build_requires      ('HTTP::Response' => '1.53');
    build_requires      ('Cache::Cache' => '1.05');
    recommends          ('Cache::FastMmap' => '1.24');
    recommends          ('Benchmark::Timer');
    recommends          ('Smart::Comments');
    recommends          ('HTTP::Server::Simple' => '0.27');
} else {
    die "Unknown Makefile.PL argument: \"$arg\"\n";
}

install_script('bin/openresty');
use_test_base();
no_index( directory => qw< etc tmp demo minisql clients doc t > );

auto_install();

# XXX This is not Windows friendly...
my $site_conf = 'etc/site_openresty.conf';
if (!-e $site_conf) {
    warn "cp etc/openresty.conf $site_conf\n";
    #print $^O;
    eval {
        require File::Copy;
    };
    if ($@) {
        my $cmd = 'cp';
        system("$cmd etc/openresty.conf $site_conf");
    } else {
        File::Copy::copy("etc/openresty.conf", $site_conf);
    }
}

system("$^X bin/revision.pl");
system("$^X bin/fetch-font.pl");

WriteAll();

