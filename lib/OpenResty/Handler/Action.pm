package OpenResty::Handler::Action;

#use Smart::Comments;
use strict;
use warnings;

use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::RestyScript;

sub POST_action_exec {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $params = {
        $bits->[2] => $bits->[3]
    };
    if ($action eq 'RunView') {
        return $self->run_view($openresty);
    }

    die "Action not found: $action\n";
}

sub run_view {
    my ($self, $openresty) = @_;

    my $sql = $openresty->{_req_data};
    ### Action sql: $sql
    if (length $sql > 5_000) { # more than 10 KB
        die "SQL input too large (must be under 5 KB)\n";
    }

    _STRING($sql) or
        die "Restyscript source must be an non-empty literal string: ", $OpenResty::Dumper->($sql), "\n";
   #warn "SQL 1: $sql\n";

    my $view = OpenResty::RestyScript->new('view', $sql);
    my ($frags, $stats) = $view->compile;
    ### $frags
    ### $stats
    if (!$frags && !$stats) { die "Failed to invoke RunView\n" }

    for my $frag (@$frags) {
        if (ref $frag) {
            die "Variables not allowed in the input to runView: $frag->[0]\n";
        }
    }

    my @models = @{ $stats->{modelList} };
    $self->validate_model_names($openresty, \@models);
    my $pg_sql = $frags->[0];

    $openresty->select($pg_sql, {use_hash => 1, read_only => 1});
}

sub append_limit_offset {
    my ($self, $openresty, $sql, $res) = @_;
    #my $order_by $cgi->url
    my $limit = $res->{limit};
    if (defined $limit) {
        $sql =~ s/;\s*$/ limit $limit/s or
            $sql .= " limit $limit";
    }
    my $offset = $res->{offset};
    if (defined $offset) {
        $sql =~ s/;\s*$/ offset $offset;/s or
            $sql .= " offset $offset";
    }
    return "$sql;\n";
}

sub validate_model_names {
    my ($self, $openresty, $models) = @_;
    for my $model (@$models) {
        _IDENT($model) or die "Bad model name: \"$model\"\n";
        if (!$openresty->has_model($model)) {
            die "Model \"$model\" not found.\n";
        }
    }
}

1;

