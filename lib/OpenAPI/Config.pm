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
    if (!$OpenAPI::Config{'cache.type'}) {
        warn "backend.type=mmap\n" if $do_echo;
        $OpenAPI::Config{'cache.type'} = 'mmap';
    }
    $OpenAPI::Limits::RECORD_LIMIT = $OpenAPI::Config{'frontend.row_limit'};
    $OpenAPI::Limits::COLUMN_LIMIT = $OpenAPI::Config{'frontend.column_limit'};
    $OpenAPI::Limits::MODEL_LIMIT = $OpenAPI::Config{'frontend.model_limit'};
    $OpenAPI::Limits::POST_LEN_LIMIT = $OpenAPI::Config{'frontend.post_len_limit'};
}

1;

