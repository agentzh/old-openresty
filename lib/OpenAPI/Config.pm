package OpenAPI::Config;

use strict;
use warnings;

use FindBin;
use Config::Simple;
use Hash::Merge;

sub init {
    my ($class, $root_path) = @_;
    $root_path ||= "$FindBin::Bin/..";
    my $path = "$root_path/etc/openapi.conf";
    my $config = new Config::Simple($path) or
        die "Cannot open config file $path\n";
    my $default_vars = $config->vars;
    $path = "$root_path/etc/site_openapi.conf";
    $config = new Config::Simple($path) or
        die "Cannot open config file $path\n";
    my $site_vars = $config->vars;
    my $vars = Hash::Merge::merge($site_vars, $default_vars);
    my $cmd = $ENV{OPENAPI_COMMAND};
    my $do_echo;
    if ($cmd and $cmd eq 'start') { $do_echo = 1; }
    while (my ($key, $val) = each %$vars) {
        $val = '' if !defined $val;
        warn "$key=$val\n" if $do_echo;
        $OpenAPI::Config ||= {};
        $OpenAPI::Config{$key} = $val;
    }
    ### $vars
    if (!$OpenAPI::Config{'backend.type'}) {
        warn "backend.type=Pg\n" if $do_echo;
        $OpenAPI::Config{'backend.type'} = 'Pg';
    }
}

1;

