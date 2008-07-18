#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use WWW::OpenResty::Simple;
use JSON::XS;
use Encode qw(decode encode);
use YAML::Syck qw(DumpFile LoadFile);

my $conf_file = '.blog.conf';
my $help;

my $cmd = shift or die usage();
if ($cmd eq '--help' or $cmd eq '-h') {
    print usage();
    exit;
}
if ($cmd eq 'init') {
    my $server = 'api.openresty.org';
    GetOptions(
        'help'     => \$help,
        'server=s' => \$server,
        'user=s' => \(my $user),
        'password=s' => \(my $password),
    ) or die usage();
    if ($help) { print usage(); exit; }
    if (!$user) { die "No --user specified.\n"; }
    #if (!$password) { die "No --password specified.\n"; }
    $password ||= '';
    my $resty = WWW::OpenResty::Simple->new(
        { server => $server }
    );
    $resty->login($user, $password);
    my $config = {
        user     => $user,
        password => $password,
        server   => $server,
    };
    DumpFile($conf_file, $config);
    warn "Wrote $conf_file.\n";
    exit;
}

my $config;
eval {
    $config = LoadFile('.blog.conf');
};
if ($@) {
    warn $@;
}
if (!$config) {
    die "Can't load the config file, have you run '$0 init' first?\n";
}
my $resty = WWW::OpenResty::Simple->new(
    { server => $config->{server} }
);
$resty->login($config->{user}, $config->{password});

if ($cmd eq 'post') {
    my %opts;
    GetOptions(
        'title=s' => \(my $title),
        'author=s' => \(my $author)
    ) or die usage();
    if (!$title) { die "No --title specified.\n"; }
    if (!$author) { die "No --author specified.\n"; }
    my $html;
    while (<>) {
        $html .= decode('utf8', $_);
    }
    my $res = $resty->post(
        '/=/model/Post/~/~',
        {
            title => $title,
            author => $author,
            content => $html,
        }
    );
    #print encode_json($res), "\n";
    print $res->{last_row} || 'Failed', "\n";
} elsif ($cmd eq 'delpost') {
    my $id = shift or die "No id specified\n";
    my $res = $resty->get("/=/model/Post/id/$id");
    if (!@$res) { die "Post not found.\n"; }
    my $elem = $res->[0];
    (my $created = $elem->{created}) =~ s/\:\d+\+\d+$//;
    print STDERR "Are you sure to delete the post titled \"$elem->{title}\" sent by $elem->{author} at $created? (Y|N)";
    while (my $ans = <STDIN>) {
        if ($ans =~ /^[Yy]/) {
            my $res = $resty->delete("/=/model/Post/id/$id");
            warn "Removed $res->{rows_affected} record(s).\n";
            last;
        } elsif ($ans =~ /^[Nn]/) {
            exit;
        }
    }
} else {
    die "Command $cmd not recognized. See --help for usage.\n";
}

sub usage {
    return <<"_EOC_";
$0 <command> <options>
Commands:
    init --server <host> --user <s> --password <s>
                                    Initialize the .blog.conf file
    post --title <s> --author <s>   Post a new post (content from STDIN)
    delpost <id>                    Delete a post by ID
    delcmt  <id>                    Delete a comment by ID
_EOC_
}

