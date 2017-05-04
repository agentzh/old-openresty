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

our $Dispatcher;

BEGIN {
    my $root_path = "$FindBin::Bin/..";
    my $filename = 'compiled.views';

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
    #warn "Key: $key\n";
    my $res = $Dispatcher->{$key} or die "Can't find the compiled form for view \"$view\"";
    my ($required_params, $hdl) = @$res;
    $hdl = eval $hdl;
    if ($@) { die "Failed to eval the handler: $@\n" }
    while (my ($key, $val) = each %$required_params) {
        next if !$key;
        my $user_val = substr($key, 0, 1) eq '_' ?
            $openresty->builtin_param($key) : $openresty->url_param($key);
        if (!defined $user_val || $user_val ne $val) {
            die "Required params do not meet for view \"$view\": $key\n";
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
    my $sql = $hdl->(\%vars);
        #warn "!!!!! $sql";
    $openresty->set_user($user);
    return $openresty->select($sql, { use_hash => 1, read_only => 1 });
}

1;
__END__

=head1 NAME

OpenResty::Handler::CompiledView - Handler for pre-compiled views

=head1 DESCRIPTION

It loads compiled.views file from etc/ or /etc/openresty/ (in such an order).

A sample compiled.views looks like this:

    use OpenResty::QuasiQuote::SQL;
    {
        'yquestion|getquery' => [
            { _user => 'yquestion.Public' },
            sub {
                my ($openresty, $vars) = @_;
                #$resty->set_use
                my $query = $vars->{spell};
                return [:sql|select * from getquery($query) as (query text, pop integer, des text) limit 10 |];
            }
        ],
    }


=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

