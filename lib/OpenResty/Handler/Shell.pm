package OpenResty::Handler::Shell;

use strict;
use warnings;

use IPC::Run qw( run timeout );
use OpenResty::Util;
use base 'OpenResty::Handler::Base';

__PACKAGE__->register('shell');

sub requires_acl { undef }

sub level2name {
    qw< prog_list prog prog_param prog_run > [$_[-1]]
}

sub GET_prog_list { # GET /=/shell
    my ($self, $openresty, $bits) = @_;
    my @paths = split /[:;]/, $ENV{PATH};
    my @progs;
    for my $path (@paths) {
        #warn "$path\n";
        my $dir;
        my $res = opendir $dir, $path;
        next if !$res;
        push @progs, grep { -f "$path/$_" && -X "$path/$_" } readdir $dir;
        close $dir;
    }
    @progs = sort @progs;
    return \@progs;
}

sub GET_prog { # GET /=/shell/prog
    my ($self, $openresty, $bits) = @_;
    my $prog_name = $bits->[1];  # $bits->[0] eq 'shell' ;)
    run ['which', $prog_name], \undef, \(my $out), \(my $err), timeout(2);
    if ($? != 0) {
        die "Can't find program $prog_name: $err\n";
    }
    chop $out;
    return $out;
}

sub GET_prog_run {
    my ($self, $openresty, $bits) = @_;
    my $prog_name = $bits->[1];  # $bits->[0] eq 'shell' ;)
    my @cmd = $prog_name;
    if ($bits->[2] ne '~') {
        push @cmd, gen_option(@$bits[2..3]);
    }
    for my $var ($openresty->url_param) {
        my $val = $openresty->url_param($var);
        push @cmd, gen_option($var, $val);
        #warn "$var => $val\n";
    }
    run \@cmd, \undef, \(my $out), \(my $err), timeout(2);
    #warn "@cmd\n";
    if ($? != 0) {
        die "Failed to call program $prog_name: $err\n";
    }
    return $out;
}

sub gen_option {
    my ($param, $val) = @_;
    my $opt = '';
    if (length $param == 1) {
        $opt .= "-$param";
    } else {
        $opt .= "--$param";
    }
    if ($val ne '""') {
        $opt .= $val;
    }
    $opt;
}

1;
__END__

=head1 NAME

OpenResty::Handler::Shell - Example Shell API for OpenResty custom handlers

=head1 SYNOPSIS

    # list all executables in PATH
    GET /=/shell

    # get the path of the "ls" program
    GET /=/shell/ls

    # call the "ls" program
    GET /=/shell/ls/~/~

    # call "ls -a"
    GET /=/shell/ls/~/~?a

=head1 DESCRIPTION

This handler is merely served as a simple and also funny sample custom handler for users who want to write their own handlers.

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

