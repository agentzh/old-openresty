package OpenResty::Script::Compile;

#use Smart::Comments;

use strict;
use warnings;

use Data::Dumper;
use CGI::Simple;

use OpenResty::RestyScript;
use OpenResty::Util qw(Q QI);
use OpenResty::QuasiQuote::SQL;

local $| = 1;

sub go {
    my $urls = pop;
    my $data = {};
    for my $url (@$urls) {
        print "Compiling \"$url\"...\n";
        $url =~ s{.*?(/=/)}{$1};
        $url =~ s{^/+}{}g;

        (my $query = $url) =~ s/(.*?\?)//g;
        #$query;
        my $cgi = bless {}, 'CGI::Simple';
        #die $ENV{'QUERY_STRING'};
        $cgi->_parse_params( $query );
        my (%required_params, @view_params);
        for my $param ($cgi->param) {
            next if !$param;
            if (substr($param, 0, 1) eq '_') {
                $required_params{$param} = $cgi->param($param);
            } else {
                push @view_params, $param;
            }
        }

        (my $path = $url) =~ s{\?.*}{};
        my @bits = split /\//, $path, 5;
        my $prefix = shift @bits;
        if ($prefix ne '=') {
            die "The url does not look like an OpenResty resource to me: $url.\n";
        }
        if ($bits[0] ne 'view') {
            die "Sorry, only view supported.\n";
        }
        if (@bits != 4) {
            die "Sorry, only view calling URLs can be compiled.\n";
        }
        my $view = $bits[1];
        my ($fix_var, $fix_var_value) = ($bits[2], $bits[3]);
        if ($fix_var ne '~') {
            push @view_params, $fix_var;
        }
        my $user = $required_params{_user} or
            die "_user params not found in $url\n";
        my ($key, $account);
        if ($user =~ /^\w+/) {
            $account = $&;
            $key = "$account|$view";
        } else {
            die "Invalid user: $user\n";
        }

        ### $view
        ### %required_params
        ### @view_params
        ### $account
        ### $key
        my $backend = $OpenResty::Backend;
        if ( ! $backend->has_user($account) ) {
            die "Account $account does not exist.\n";
        }
        $backend->set_user($account);
        my $minisql = $backend->select(
            [:sql| select definition from _views where name = $view limit 1 |],
            {use_hash => 1}
        )->[0]->{definition};
        my %default;
        $minisql =~ s/\$(\w+)\s*\|\s*(\S+)/$default{$1} = $2;'$'.$1/ge;
        ### $minisql
        my $restyscript = OpenResty::RestyScript->new('view', $minisql);
        my ($frags) = $restyscript->compile;
        ### $frags
        my (@code_bits, %vars);
        for my $frag (@$frags) {
            if (ref $frag) {  # being a variable
                my ($var, $type) = @$frag;
                if ($type eq 'symbol') {
                    push @code_bits, "QI(\$$var)";
                } else {
                    push @code_bits, "Q(\$$var)";
                }
                $vars{$var} = 1;
            } else {
                $frag =~ s/\\/\\\\/g;
                $frag =~ s/'/\\'/g;
                push @code_bits, "'$frag'";
            }
        }
        my $build_sql = join '.', @code_bits;

        my $get_args = join '',
            map {
                "my \$$_ = \$vars->{$_}" .
                (defined $default{$_} ? " || $default{$_};" : ';')
            } keys %vars;
        $data->{$key} = [
            \%required_params,
            qq/sub { my \$vars = shift; $get_args return $build_sql }/,
        ];
    }
    my $outfile = 'compiled.views';

    my $perl = Dumper($data);
    $perl =~ s/^\$VAR1 = //ms;
    open my $out, ">$outfile" or
        die "Can't open $outfile for writing: $!\n";
    print $out <<_EOC_;
use OpenResty::QuasiQuote::SQL;
$perl
_EOC_
    close $out;
    print "$outfile generated.\n\tYou may want to put it under etc/ or /etc/openresty/ for OpenResty's CompiledView handler to load at startup.\n";
}

1;
