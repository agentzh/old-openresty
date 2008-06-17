package OpenResty::Handler::View;

use strict;
use warnings;

use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::Limits;
use OpenResty::RestyScript::View;

sub POST_view {
    my ($self, $openresty, $bits) = @_;
    my $data = _HASH($openresty->{_req_data}) or
        die "The view schema must be a HASH.\n";
    my $view = $bits->[1];

    my $name;
    if ($view eq '~') {
        $view = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $view) {
        $openresty->warning("name \"$name\" in POST content ignored.");
    }

    $data->{name} = $view;
    return $self->new_view($openresty, $data);
}

sub get_views {
    my ($self, $openresty, $params) = @_;
    my $select = OpenResty::SQL::Select->new(
        qw< name description >
    )->from('_views');
    return $openresty->select("$select", { use_hash => 1 });
}

sub GET_view_list {
    my ($self, $openresty, $bits) = @_;
    my $views = $self->get_views($openresty);
    $views ||= [];

    map { $_->{src} = "/=/view/$_->{name}" } @$views;
    $views;
}

sub GET_view {
    my ($self, $openresty, $bits) = @_;
    my $view = $bits->[1];

    if ($view eq '~') {
        return $self->get_views($openresty);
    }
    if (!$openresty->has_view($view)) {
        die "View \"$view\" not found.\n";
    }
    my $select = OpenResty::SQL::Select->new( qw< name definition description > )
        ->from('_views')
        ->where(name => Q($view));

    return $openresty->select("$select", {use_hash => 1})->[0];
}

sub PUT_view {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $view = $bits->[1];
    my $data = _HASH($openresty->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    ### $view
    ### $data
    die "View \"$view\" not found.\n" unless $openresty->has_view($user, $view);

    my $update = OpenResty::SQL::Update->new('_views');
    $update->where(name => Q($view));

    my $new_name = delete $data->{name};
    if (defined $new_name) {
        _IDENT($new_name) or
            die "Bad view name: ", $OpenResty::Dumper->($new_name), "\n";
        $OpenResty::Cache->remove_has_view($user, $view);
        $update->set( name => Q($new_name) );
    }

    my $new_def = delete $data->{definition};
    if (defined $new_def) {
        _STRING($new_def) or
            die "Bad view definition: ", $OpenResty::Dumper->($new_def), "\n";
        $update->set(definition => Q($new_def));
    }

    my $new_desc = delete $data->{description};
    if (defined $new_desc) {
        _STRING($new_desc) or die "Bad view description: ", $OpenResty::Dumper->($new_desc), "\n";
        $update->set(description => Q($new_desc));
    }
    ### Update SQL: "$update"
    if (%$data) {
        die "Unknown keys in POST data: ", join(' ', keys %$data), "\n";
    }

    my $retval = $openresty->do("$update") + 0;
    return { success => $retval >= 0 ? 1 : 0 };
}

sub exec_view {
    my ($self, $openresty, $view, $bits, $cgi) = @_;
    my $select = OpenResty::RestyScript::View->new;
    my $sql = "select definition from _views where name = " . Q($view);
    ### laser exec_view: "$sql"
    my $view_def = $openresty->select($sql)->[0][0];
    my $fix_var = $bits->[2];
    _IDENT($fix_var) or $fix_var eq '~' or die "Bad parameter name: ", $OpenResty::Dumper->($fix_var), "\n";
    my $fix_var_value = $bits->[3];
    my $exists;
    my %vars;

    foreach my $var ($cgi->url_param) {
        $vars{$var} = $cgi->url_param($var);
    }

    if ($fix_var ne '~' and $fix_var_value ne '~') {
        $vars{$fix_var} = $fix_var_value;
    }

    my $res;
    eval {
        $res = $select->parse(
            $view_def,
            { quote => \&Q, quote_ident => \&QI, vars => \%vars }
        );
    };
    if ($@) {
        die "minisql: $@\n";
    }

    my @unbound = @{ $res->{unbound} };
    if (@unbound) {
        die "Parameters required: @unbound\n";
    }
    return $openresty->select($res->{sql}, { use_hash=>1, read_only=>1 });

}

sub GET_view_exec {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $view = $bits->[1];

    die "View \"$view\" not found.\n" unless $openresty->has_view($user, $view);
    return $self->exec_view($openresty, $view, $bits, $openresty->{_cgi});
}

sub view_count {
    my ($self, $openresty) = @_;
    return $openresty->select("select count(*) from _views")->[0][0];
}

sub new_view {
    my ($self, $openresty, $data) = @_;
    my $nviews = $self->view_count($openresty);
    my $res;
    if ($nviews >= $VIEW_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded view count limit $VIEW_LIMIT.\n";
    }

    my $name = delete $data->{name} or
        die "No 'name' specified.\n";
    _IDENT($name) or die "Bad view name: ", $OpenResty::Dumper->($name), "\n";
    if ($openresty->has_view($name)) {
        die "View \"$name\" already exists.\n";
    }

    my $minisql = delete $data->{definition};
    if (!defined $minisql) {
        die "No 'definition' specified.\n";
    }
    _STRING($minisql) or die "Bad definition: ", $OpenResty::Dumper->($minisql), "\n";

    my $desc = delete $data->{description};
    if (defined $desc) {
        _STRING($desc) or die "View description must be a string.\n";
    }

    if (%$data) {
        die "Unknown keys: ", join(" ", keys %$data), "\n";
    }

    my $select = OpenResty::RestyScript::View->new;
    eval {
        $res = $select->parse(
            $minisql,
            { quote => \&Q, quote_ident => \&QI }
        );
    };
    if ($@) {
        die "minisql: $@\n";
    }

    #
    # check to see if modes exists
    #
    my @models = @{ $res->{models} };
    foreach my $model (@models){
        next if $model =~ /^\s*$/;
        if (!$openresty->has_model($model)) {
            die "Model \"$model\" not found.\n";
        }
    }

    my $insert = OpenResty::SQL::Insert
        ->new('_views')
        ->cols( qw<name definition description> )
        ->values( Q($name, $minisql, $desc) );

    return { success => $openresty->do("$insert") ? 1 : 0 };

}

sub DELETE_view {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $view = $bits->[1];
    _IDENT($view) or $view eq '~' or
        die "Bad view name: ", $OpenResty::Dumper->($view), "\n";
    if ($view eq '~') {
        return $self->DELETE_view_list($openresty);
    }
    if (!$openresty->has_view($view)) {
        die "View \"$view\" not found.\n";
    }
    $OpenResty::Cache->remove_has_view($user, $view);
    my $sql = "delete from _views where name = " . Q($view);
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_view_list {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;

    my $views = $self->get_views($openresty);
    for my $view (@$views) {
        $OpenResty::Cache->remove_has_view($user, $view);
    }
    my $sql = "truncate _views;";
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

1;

