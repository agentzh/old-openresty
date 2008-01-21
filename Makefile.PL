use strict;
use inc::Module::Install '0.46';

name                ('OpenAPI');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenAPI.pm');

requires            ('perl' => '5.008001');
requires            ('CGI' => '3.33');
requires            ('FCGI');
requires            ('YAML::Syck' => '1.00');
requires            ('List::Util');
requires            ('DBI' => '1.57');
requires            ('Clone' => '0.22');
requires            ('Params::Util' => '0.22');
requires            ('Parse::Yapp');
requires            ('DBD::Pg' => '1.49');
requires            ('Term::ReadKey' => '2.30');
requires            ('Data::UUID' => '1.148');
requires            ('GD::SecurityImage' => '1.64');
requires            ('Cache::Memcached::Fast' => '0.06');
requires            ('Hash::Merge'),
requires            ('Config::Simple'),

features(
    'Test suite' => [
        -default => 0,
        recommends    ('Cache::FastMmap' => '1.24'),
        recommends    ('Smart::Comments'),
        recommends    ('Class::Prototyped' => '1.11'),
        recommends    ('Test::LongString' => 0.11),
        recommends    ('Test::Base' => 0.54),
        recommends    ('Test::More' => 0.74),
        recommends    ('LWP::UserAgent'),
        recommends    ('Benchmark::Timer'),
        recommends    ('HTTP::Server::Simple' => '0.27'),
    ]
);

auto_install();

# XXX This is not Windows friendly...
my $site_conf = 'etc/site_openapi.conf';
if (!-e $site_conf) {
    warn "cp etc/openapi.conf $site_conf\n";
    my $cmd = $^O =~ /win32/ ? 'copy' : 'cp';
    system("$cmd etc/openapi.conf $site_conf");
}

system("$^X bin/revision.pl");
system("$^X bin/fetch-font.pl");

WriteAll();

