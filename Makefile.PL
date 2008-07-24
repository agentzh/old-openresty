use strict;
use lib '.';
use inc::Module::Install;

name                ('OpenResty');
license             ('artistic2');
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

requires            ('Cookie::XS' => '0.09');
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
#requires            ('List::MoreUtils');
requires            ('Config::Simple');
requires            ('Encode::Guess');
requires            ('List::MoreUtils');
requires            ('JSON::XS' => '2.2');
requires            ('Data::Structure::Util' => '0.15');
requires            ('DateTime::Format::Pg');
requires            ('DateTime::Format::Strptime');
requires            ('Digest::MD5');
requires            ('File::ShareDir');
# modules needed by new captcha mechanism
requires			('Crypt::CBC');
requires			('Crypt::Rijndael');
requires                        ('IPC::Run3');
requires                        ('IPC::Run');
requires                        ('Time::HiRes');

recommends          ('Benchmark::Timer');
recommends          ('HTTP::Server::Simple' => '0.27');
recommends          ('Text::Diff');
recommends          ('Text::Table');
recommends          ('Term::ReadLine::Perl');
recommends          ('Term::ReadLine::Gnu');

if ($arg eq 'product') {
    features(
        'Test suite' => [
            -default => 0,
                recommends    ('Term::ReadKey' => '2.30'),
                recommends    ('CGI' => '3.33'),
                recommends    ('Cache::Cache' => '1.05'),
                recommends    ('Class::Prototyped'),
                recommends    ('Test::LongString'),
                recommends    ('HTTP::Response' => '1.53'),
                recommends    ('WWW::OpenResty' => '0.06'),
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
    build_requires      ('WWW::OpenResty' => '0.06'),
} else {
    die "Unknown Makefile.PL argument: \"$arg\"\n";
}

#recommends          ('Cache::FastMmap' => '1.24');

install_script('bin/openresty');
if (-f 'haskell/bin/restyscript') {
    install_script('haskell/bin/restyscript');
}

use_test_base();
no_index( directory => qw< etc misc tmp demo minisql clients doc t > );

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

my $message = "Download the Chinese font file (14 MB) from agentzh.org to get Chinese captcha support? [n]";
my $ans = prompt($message);
if ($ans && $ans =~ /y/i) {
    system("$^X bin/fetch-font.pl");
}

install_share;

WriteAll();

