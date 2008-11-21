package OpenResty::Config;

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use Config::Simple;
use Hash::Merge;

our $Initialized = undef;

sub to_num ($) {
    (my $s = $_[0]) =~ s/_//g;
    $s;
}

sub init {
    return if $Initialized;
    $Initialized = 1;
    my ($class, $opts) = @_;
    # warn "$opts->{'conf_file'}";
    my $root_path;
    if (defined $opts->{root_path}) {
        $root_path = $opts->{root_path};
    } else {
        $root_path = File::Spec->catfile($FindBin::Bin, "..");
    }

    my $os_root = File::Spec->rootdir();
    my $os_cur_dir = File::Spec->curdir();

    my $path = File::Spec->catfile($root_path, 'etc', 'openresty.conf');
    $path = File::Spec->catfile($os_root, "etc", "openresty", "openresty.conf") if (!-f $path);
    die "Config file $path not found.\n" if (!-f $path);

    my $config = new Config::Simple($path) or
        die "Cannot open config file $path\n";
    my $default_vars = $config->vars;

    my $conf_file = $opts->{conf_file};
    if (defined $conf_file) {
        my $is_absolute = File::Spec->file_name_is_absolute($conf_file);
        if ($is_absolute) {
            $path = $conf_file;
        } else {
            $path = File::Spec->catfile($os_cur_dir, $conf_file);
        }
        die "Config file $path not found or not a file.\n" if (!-f $path);
    } else {
        $path = File::Spec->catfile($root_path, 'etc', 'site_openresty.conf');
        $path = File::Spec->catfile($os_root, "etc", "openresty", "site_openresty.conf") if (!-f $path);
        die "Config file $path not found.\n" if (!-f $path);
    }
    # warn $path;
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
        warn "cache.type=mmap\n" if $do_echo;
        $OpenResty::Config{'cache.type'} = 'mmap';
    }
    $OpenResty::Limits::RECORD_LIMIT = to_num
        $OpenResty::Config{'frontend.row_limit'};
    $OpenResty::Limits::INSERT_LIMIT = to_num
        $OpenResty::Config{'frontend.bulk_insert_limit'};
    $OpenResty::Limits::COLUMN_LIMIT = to_num
        $OpenResty::Config{'frontend.column_limit'};
    $OpenResty::Limits::MODEL_LIMIT = to_num
        $OpenResty::Config{'frontend.model_limit'};
    $OpenResty::Limits::POST_LEN_LIMIT = to_num
        $OpenResty::Config{'frontend.post_len_limit'};

    $CGI::Simple::POST_MAX = to_num $OpenResty::Limits::POST_LEN_LIMIT;
    # max 100 K posts
    $CGI::Simple::DISABLE_UPLOADS = 1;  # no uploads
    my $list = $OpenResty::Config{'frontend.allow_forwarding'};
    if ($list) {
        my @accounts = split /\s+/, $list;
        for my $account (@accounts) {
            #warn "Allowing account $account...\n";
            $OpenResty::AllowForwarding{$account} = 1;
        }
    }
}

1;
__END__

=head1 NAME

OpenResty::Config - Configure file reader for OpenResty

=head1 SYNOPSIS

    use OpenResty::Config;
    OpenResty::Config->init;
    print $OpenResty::Config{'foo.bar'}; # read the config option's value

=head1 DESCRIPTION

This module reads the configure settings from the config files.

The OpenResty server usually loads two config files, i.e., F<openresty.conf> and F<site_openresty.conf>.

The config files use the synatx similar to F<.ini> files native to Win32 systems. The underlying file reader is actually L<Config::Simple>.

The steps of determining the paths searched for these two config files and the merging algorithm of these two files' settings are given below:

=over

=item 1.

Look for the config file F<$FindBin::Bin/../etc/openresty.conf>. If
it does not exist or is not a file, it tries to look for
F</etc/openresty/openresty.conf>.

=item 2.

Loads the config settings in the config file determined in step 1 to a
hash, say, Hash A.

=item 3.

If you set the option -f, the openresty will load the config file you set,

or the openresty will look for the config file

F<$FindBin::Bin/../etc/site_openresty.conf>. If it does not exist or

is not a file, it tries to look for F</etc/openresty/site_openresty.conf>.

=item 4.

Loads the config settings in the config file determined in step 3 to a
hash, say, Hash B.

=item 5.

Merge Hash A obtained in step 2 and Hash B in step 4 using
L<Hash::Merge>. The settings in F<site_openresty.conf> takes the priority
over the same setting in F<openresty.conf>.

If an option setting is
completely missing in F<site_openresty.conf>, then the setting for the same option in F<openresty.conf> (if any) will be used. Note, however, fall-back won't happen when F<site_openresty> has an option with an empty string value, as in

    [frontend]
    ...
    filtered=

So in order to use the C<frontend.filtered> setting in the F<openresty.conf> file, one has to remove the whole line altegether or just comment it out like this:

    [frontend]
    ...
    #filtered=

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn >>.

=head1 SEE ALSO

L<OpenResty::Limits>, L<OpenResty>.

