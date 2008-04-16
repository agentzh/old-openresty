package OpenResty::Handler::Action;

#use Smart::Comments;
use strict;
use warnings;

use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::RestyScript::View;

sub POST_action_exec {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $params = {
        $bits->[2] => $bits->[3]
    };
    my $lang = $params->{lang};
    if (!defined $lang) {
        die "The 'lang' param is required in the Select action.\n";
    }
    if (lc($lang) ne 'minisql') {
        die "Only the miniSQL language is supported for Select.\n";
    }
    my $sql = $openresty->{_req_data};
    ### Action sql: $sql

    _STRING($sql) or
        die "miniSQL must be an non-empty literal string: ", $OpenResty::Dumper->($sql), "\n";
   #warn "SQL 1: $sql\n";
    my $select = OpenResty::RestyScript::View->new;
    my $res = $select->parse(
        $sql,
        {
            quote => \&Q, quote_ident => \&QI,
            limit => $openresty->{_limit}, offset => $openresty->{_offset}
        }
    );
    if (_HASH($res)) {
        my $sql = $res->{sql};
        $sql = $self->append_limit_offset($openresty, $sql, $res);
        my @models = @{ $res->{models} };
        my @cols = @{ $res->{columns} };
        $self->validate_model_names($openresty, \@models);
        $self->validate_col_names($openresty, \@models, \@cols);
       #warn "SQL 2: $sql\n";
        $openresty->select("$sql", {use_hash => 1, read_only => 1});
    }
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

sub validate_col_names {
    my ($self, $openresty, $models, $cols) = @_;
    # XXX TODO...
}

1;

