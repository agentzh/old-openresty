use strict;
use lib '.';
use inc::Module::Install;

name                ('Cookie');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenAPI.pm');

cc_inc_paths    '.';
#cc_files        (glob("*.c"), (-e 'Syck.c' ? () : 'Syck.c'));
cc_optimize_flags '-g3';
can_cc or die "This module requires a C compiler";

requires            ('perl' => '5.008001');
requires            ('FCGI');
requires            ('CGI::Simple' => '1.103');
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
        recommends    ('CGI' => '3.33'),
        recommends    ('Cache::Cache' => '1.05'),
        recommends    ('Smart::Comments'),
        recommends    ('Class::Prototyped'),
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
    #print $^O;
    eval {
        require File::Copy;
    };
    if ($@) {
        my $cmd = 'cp';
        system("$cmd etc/openapi.conf $site_conf");
    } else {
        File::Copy::copy("etc/openapi.conf", $site_conf);
    }
}

system("$^X bin/revision.pl");
system("$^X bin/fetch-font.pl");

WriteAll();

