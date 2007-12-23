use strict;
use inc::Module::Install;

name                ('OpenAPI');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenAPI.pm');

requires            ('CGI' => '3.31');
requires            ('FCGI');
requires            ('YAML::Syck' => '0.99');
requires            ('Lingua::EN::Inflect' => '1.89');
requires            ('Smart::Comments');
requires            ('List::Util');
requires            ('DBD::Pg' => '1.49');
requires            ('DBI' => '1.57');
requires            ('Params::Util' => '0.22');
requires            ('Clone' => '0.22');
requires            ('Parse::Yapp');

build_requires      ('Test::LongString' => 0.11);
build_requires      ('Test::Base' => 0.54);
build_requires      ('Test::More' => 0.74);
build_requires      ('LWP::UserAgent');
build_requires      ('Benchmark::Timer');
build_requires      ('Hash::Merge');

auto_install();
WriteAll();

