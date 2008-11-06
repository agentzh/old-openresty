package OpenResty::Handler::CompiledAction;

use strict;
use warnings;

use OpenResty::Util qw(Q QI);
use OpenResty::QuasiQuote::SQL;
use JSON::XS ();
use LWP::UserAgent;
use Data::Dumper qw(Dumper);

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('action');

sub requires_acl { undef }

sub level2name {
    qw< action_list action action_param action_exec > [$_[-1]]
}

our $Dispatcher;

BEGIN {
    my $root_path = "$FindBin::Bin/..";
    my $filename = 'compiled.actions';

    my $path = "$root_path/etc/$filename";
    unless (-f $path) {
        $path = "/etc/openresty/$filename";
    }
    if (!-f $path) {
        die "Can't find $filename under  $root_path/etc/ nor /etc/openresty/.\n";
    }
    unless ($Dispatcher = do $path) {
        die "Couldn't parse $path: $@\n" if $@;
        die "Couldn't read $path: $!\n"   unless defined $Dispatcher;
        die "Couldn't run $path\n"       unless $Dispatcher;
    }
}

my $ua = LWP::UserAgent->new;
$ua->timeout(2);

sub GET_action_exec {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];

    my $user = $openresty->builtin_param('_user') or
        die "No _user secified fro the CompiledAction handler.\n";
    my $key;
    if ($user =~ /^\w+/) {
        $user = $&;
        $key = "$user|$action";
    } else {
        die "Invalid _user param.\n";
    }
    
    my $res = $Dispatcher->{$key} or die "Can't find the compiled form for action \"$action\"";
    # warn "result: $res";
    my ($required_params, $hdl) = @$res;
    # warn "handle: $hdl\n";
    #$hdl = eval $hdl;
    #if ($@) { die "Failed to eval the handler: $@\n" }
    my $user_test = $openresty->builtin_param("_user");
    warn "_user: $user_test \n";
    while (my ($key, $val) = each %$required_params) {
        next if !$key;
        my $user_val = substr($key, 0, 1) eq '_' ?
            $openresty->builtin_param($key) : $openresty->url_param($key);
        if (!defined $user_val || $user_val ne $val) {
            die "Required params do not meet for action \"$action\": $key\n";
        }
    }
    my ($fix_var, $fix_var_value) = ($bits->[2], $bits->[3]);
    my %vars;
    for my $var ($openresty->url_param) {
        $vars{$var} = $openresty->url_param($var) unless $var =~ /^_/;
    }
    if ($fix_var ne '~' and $fix_var_value ne '~') {
        $vars{$fix_var} = $fix_var_value;
    }
    $res = $hdl->(\%vars);
    # warn $res;
    my $req = do_http_request('GET', $res);
    my @outs;
    push @outs, $req;

    return \@outs;

    #warn "!!!!! $sql";
    #$openresty->set_user($user);
    #return $openresty->select($sql, { use_hash => 1, read_only => 1 });
}

sub do_http_request {
    my ($meth, $url, $rcontent) = @_;
    #no strict 'subs';
    #### $meth
    #### $url

    my $req = HTTP::Request->new($meth);
    $req->header('Content-Type' => 'text/plain');
    $req->header('Accept', '*/*');
    $req->url($url);

    my $res = $ua->request($req);
        # judge result and next action based on $response_code
    if ($res->is_success) {
        my $content = $res->content;
        my $type = $res->header('Content-Type');
        if ($type !~ /^text\//) {
            return {
                success => 0, error => 'Text response expected.',
            };
        }

        my $data;
        eval {
            $data = $OpenResty::JsonXs->decode($content);
        };
        if ($@) {
            return $content;
        } else {
            return $data;
        }
    } else {
        return {
            success => 0, error => $res->status_line,
        };
    }
}

1;
__END__
