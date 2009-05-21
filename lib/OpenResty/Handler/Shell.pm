package OpenResty::Handler::Shell;

use strict;
use warnings;

use IPC::Run qw( run timeout );
use Params::Util qw( _STRING );
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
    for my $path (@paths)
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

sub GET_prog_run { # GET /=/shell/prog/~/~
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
    run \@cmd, \undef, \(my $out), \(my $err), timeout(1);
    #warn "@cmd\n";
    if ($? != 0) {
        die "Failed to call program $prog_name: $err\n";
    }
    return $out;
}

sub POST_prog_run { # POST /=/shell/prog/~/~
    my ($self, $openresty, $bits) = @_;
    my $prog_name = $bits->[1];
    my @cmd = $prog_name;
    if ($bits->[2] ne '~') {
        push @cmd, gen_option(@$bits[2..3]);
    }
    for my $var ($openresty->url_param) {
        my $val = $openresty->url_param($var);
        push @cmd, gen_option($var, $val);
        #warn "$var => $val\n";
    }

    my $stdin = _STRING($openresty->{_req_data}) or
        die "POST data must be a plain string.\n";

    run \@cmd, \$stdin, \(my $out), \(my $err), timeout(1);
    #warn "@cmd\n";
    if ($? != 0) {
        die "Failed to call program $prog_name: $err\n";
    }
    return $out;
}

1;
__END__

=head1 NAME

OpenResty::Handler::Shell - Example Shell API for OpenResty custom
handlers

=head1 SYNOPSIS

    # list all executables in PATH
    GET /=/shell

    # get the path of the "ls" program
    GET /=/shell/ls

    # call the "ls" program
    GET /=/shell/ls/~/~

    # call "ls -a"
    GET /=/shell/ls/~/~?a=""

    # call perl oneliner: perl -e 'hello,world'
    GET /=/shell/perl/e/print("hello,world")
        # server returns "hello,world"

    # or use POST to feed stdin: echo "print 'hello, world'"|perl -w
    POST /=/shell/perl/~/~?w=""
    "print 'hello, world'"

=head1 DESCRIPTION

This handler is merely served as a simple and also funny sample custom
handler for users who want to write their own handlers.

It's not meant to be used in the real world.

To use this Shell handler in your OpenResty setup, set the
C<frontend.handlers> to C<Shell> in your F<site_openresty.conf> file:

    [frontend]
    handlers=Shell

To simplify things here, this Shell handler bypasses the OpenResty ACL
mechansim, just like the Version and Login handler. So take care ;)
For handlers requiring login, change the following line

    sub requires_acl { undef }

to

    sub requires_acl { 1 }

or just comment it out.

Note that this handler does not require a PostgreSQL database to
function. You can use the C<Empty> backend to run this handler. For
example, in your F<site_openresty.conf> file:

    [backend]
    type=Empty

Because OpenResty's Role API replies on a working Pg backend, you
cannot use C<Empty> backend if you turns ACL on by returning true in
your C<requires_acl> sub.

Custom handler names must be under the C<OpenResty::Handler::> namespace,
e.g., C<OpenResty::Handler::Shell>. It's not required to be included in
the OpenResty source tree, just ensure it's installed into the same perl
that L<OpenResty> uses.

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

