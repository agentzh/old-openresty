use strict;
use lib '.';
use inc::Module::Install;

name                ('OpenAPI');
license             ('perl');
author              ('Agent Zhang <agentzh@yahoo.cn>');
perl_version        ('5.006001');
all_from            ('lib/OpenAPI.pm');

my $arg = shift || 'devel';
if ($arg eq 'product') {
    requires            ('FCGI');
    requires            ('CGI::Simple' => '1.103');
    requires            ('YAML::Syck' => '1.00');
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

    features(
        'Test suite' => [
            -default => 0,
                recommends    ('Term::ReadKey' => '2.30'),
                recommends    ('CGI' => '3.33'),
                recommends    ('Cache::Cache' => '1.05'),
                recommends    ('Smart::Comments'),
                recommends    ('Class::Prototyped'),
                recommends    ('Test::LongString' => 0.11),
                recommends    ('LWP::UserAgent'),
                recommends    ('Benchmark::Timer'),
                recommends    ('HTTP::Server::Simple' => '0.27'),
        ]
    );
} elsif ($arg eq 'devel') {
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
    requires            ('Hash::Merge');
    requires            ('Config::Simple');

    build_requires      ('CGI' => '3.33');
    build_requires      ('Class::Prototyped');
    build_requires      ('Test::LongString' => 0.11);
    build_requires      ('LWP::UserAgent');
    recommends          ('Cache::FastMmap' => '1.24');
    recommends          ('Benchmark::Timer');
    recommends          ('Cache::Cache' => '1.05');
    recommends          ('Smart::Comments');
    recommends          ('HTTP::Server::Simple' => '0.27');
} else {
    die "Unknown Makefile.PL argument: \"$arg\"\n";
}

install_script('bin/openapi.pl');
use_test_base();
no_index( directory => qw< etc tmp > );

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

