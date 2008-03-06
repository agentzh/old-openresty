package OpenResty::Config;

use strict;
use warnings;

use FindBin;
use Config::Simple;
use Hash::Merge;

sub init {
    my ($class, $root_path) = @_;
    $root_path ||= "$FindBin::Bin/..";
    my $path = "$root_path/etc/openresty.conf";
    my $config = new Config::Simple($path) or
        die "Cannot open config file $path\n";
    my $default_vars = $config->vars;
    $path = "$root_path/etc/site_openresty.conf";
    $config = new Config::Simple($path) or
        die "Cannot open config file $path\n";
    my $site_vars = $config->vars;
    my $vars = Hash::Merge::merge($site_vars, $default_vars);
    my $cmd = $ENV{OPENRESTY_COMMAND};
    my $do_echo;
    if ($cmd and $cmd eq 'start') { $do_echo = 1; }
    while (my ($key, $val) = each %$vars) {
        $val = '' if !defined $val;
        warn "$key=$val\n" if $do_echo;
        $OpenResty::Config ||= {};
        $OpenResty::Config{$key} = $val;
    }
    ### $vars
    if (!$OpenResty::Config{'backend.type'}) {
        warn "backend.type=Pg\n" if $do_echo;
        $OpenResty::Config{'backend.type'} = 'Pg';
    }
    if (!$OpenResty::Config{'cache.type'}) {
        warn "backend.type=mmap\n" if $do_echo;
        $OpenResty::Config{'cache.type'} = 'mmap';
    }
    $OpenResty::Limits::RECORD_LIMIT = $OpenResty::Config{'frontend.row_limit'};
    $OpenResty::Limits::COLUMN_LIMIT = $OpenResty::Config{'frontend.column_limit'};
    $OpenResty::Limits::MODEL_LIMIT = $OpenResty::Config{'frontend.model_limit'};
    $OpenResty::Limits::POST_LEN_LIMIT = $OpenResty::Config{'frontend.post_len_limit'};

    $CGI::Simple::POST_MAX = $OpenResty::Limits::POST_LEN_LIMIT;  # max 100 K posts
    $CGI::Simple::DISABLE_UPLOADS = 1;  # no uploads
}

1;

