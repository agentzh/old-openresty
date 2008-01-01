use strict;
use inc::Module::Install '0.46';

name                ('OpenAPI');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenAPI.pm');

requires            ('CGI' => '3.32');
requires            ('FCGI');
requires            ('YAML::Syck' => '0.99');
requires            ('List::Util');
requires            ('DBI' => '1.57');
requires            ('Clone' => '0.22');
requires            ('Params::Util' => '0.22');
requires            ('Parse::Yapp');
requires            ('DBD::Pg' => '1.49');

features(
    'Test suite' => [
        -default => 0,
        recommends    ('Smart::Comments'),
        recommends    ('Test::LongString' => 0.11),
        recommends    ('Test::Base' => 0.54),
        recommends    ('Test::More' => 0.74),
        recommends    ('LWP::UserAgent'),
        recommends    ('Benchmark::Timer'),
        recommends    ('Hash::Merge'),
        recommends    ('HTTP::Server::Simple' => '0.27'),
    ]
);

auto_install();
WriteAll();

