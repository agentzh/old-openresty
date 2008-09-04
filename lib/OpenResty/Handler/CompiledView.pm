package OpenResty::Handler::CompiledView;

use strict;
use warnings;

use OpenResty::Util qw( Q QI );
use OpenResty::QuasiQuote::SQL;

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('view');

sub requires_acl { undef }

sub level2name {
    qw< view_list view view_param view_exec >[$_[-1]]
}

# XXX merely a hard-coded hack...
my %Views = (
    'yquestion|getquery' => [
        { _user => 'yquestion.Public' },
        sub {
            my ($openresty, $vars) = @_;
            #$resty->set_use
            my $query = $vars->{spell};
            return [:sql|select * from getquery($query) as (query text, pop integer, des text) limit 10 |];
        }
    ],
);

sub GET_view_exec {
    my ($self, $openresty, $bits) = @_;
    my $view = $bits->[1];
    my $user = $openresty->builtin_param('_user') or
        die "No _user specified for the CompiledView handler.\n";
    my $key;
    if ($user =~ /^\w+/) {
        $user = $&;
        $key = "$user|$view";
    } else {
        die "Invalid _user param.\n";
    }
    warn "Key: $key\n";
    my $res = $Views{$key} or die "Can't find the compiled form for view \"$view\"";
    my ($required_params, $hdl) = @$res;
    while (my ($key, $val) = each %$required_params) {
        my $user_val = $openresty->url_param($key);
        if (!defined $user_val || $user_val ne $val) {
            die "Required params do not meet for view \"$view\".\n";
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
    my $sql = $hdl->($openresty, \%vars);
        #warn "!!!!! $sql";
    $openresty->set_user($user);
    return $openresty->select($sql, {use_hash => 1});
}

1;
