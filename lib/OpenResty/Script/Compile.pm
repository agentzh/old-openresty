package OpenResty::Script::Compile;

use Smart::Comments;

use strict;
use warnings;
use CGI::Simple;

sub go {
    my $urls = pop;
    for my $url (@$urls) {
        warn "Compiling $url...\n";
        $url =~ s{.*?(/=/)}{$1};
        $url =~ s{^/+}{}g;

        (my $query = $url) =~ s/(.*?\?)//g;
        $query;
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
    }
}

1;
