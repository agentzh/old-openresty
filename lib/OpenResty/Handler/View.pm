package OpenResty;

use strict;
use warnings;
use vars qw($Dumper);

sub POST_view {
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The view schema must be a HASH.\n";
    my $view = $bits->[1];

    my $name;
    if ($view eq '~') {
        $view = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $view) {
        $self->warning("name \"$name\" in POST content ignored.");
    }

    $data->{name} = $view;
    return $self->new_view($data);
}

sub get_views {
    my ($self, $params) = @_;
    my $select = SQL::Select->new(
        qw< name description >
    )->from('_views');
    return $self->select("$select", { use_hash => 1 });
}

sub GET_view_list {
    my ($self, $bits) = @_;
    my $views = $self->get_views;
    $views ||= [];

    map { $_->{src} = "/=/view/$_->{name}" } @$views;
    $views;
}

sub GET_view {
    my ($self, $bits) = @_;
    my $view = $bits->[1];

    if ($view eq '~') {
        return $self->get_views;
    }
    if (!$self->has_view($view)) {
        die "View \"$view\" not found.\n";
    }
    my $select = SQL::Select->new( qw< name definition description > )
        ->from('_views')
        ->where(name => Q($view));

    return $self->select("$select", {use_hash => 1})->[0];
}

sub PUT_view {
    my ($self, $bits) = @_;
    my $view = $bits->[1];
    my $data = _HASH($self->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    ### $view
    ### $data
    die "View \"$view\" not found.\n" unless $self->has_view($view);

    my $update = SQL::Update->new('_views');
    $update->where(name => Q($view));

    my $new_name = delete $data->{name};
    if (defined $new_name) {
        _IDENT($new_name) or
            die "Bad view name: ", $Dumper->($new_name), "\n";
        $update->set( name => Q($new_name) );
    }

    my $new_def = delete $data->{definition};
    if (defined $new_def) {
        _STRING($new_def) or
            die "Bad view definition: ", $Dumper->($new_def), "\n";
        $update->set(definition => Q($new_def));
    }

    my $new_desc = delete $data->{description};
    if (defined $new_desc) {
        _STRING($new_desc) or die "Bad view description: ", $Dumper->($new_desc), "\n";
        $update->set(description => Q($new_desc));
    }
    ### Update SQL: "$update"
    if (%$data) {
        die "Unknown keys in POST data: ", join(' ', keys %$data), "\n";
    }

    my $retval = $self->do("$update") + 0;
    return { success => $retval >= 0 ? 1 : 0 };
}

sub exec_view {
    my ($self,$view, $bits, $cgi) = @_;
    my $select = MiniSQL::Select->new;
    my $sql = "select definition from _views where name = " . Q($view);
    ### laser exec_view: "$sql"
    my $view_def = $self->select($sql)->[0][0];
    my $fix_var = $bits->[2];
    _IDENT($fix_var) or $fix_var eq '~' or die "Bad parameter name: ", $Dumper->($fix_var), "\n";
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
    return $self->select($res->{sql}, { use_hash=>1, read_only=>1 });

}

sub GET_view_exec {
    my ($self, $bits) = @_;
    my $view = $bits->[1];

    die "View \"$view\" not found.\n" unless $self->has_view($view);
    return $self->exec_view($view, $bits, $self->{_cgi});
}

sub view_count {
    my $self = shift;
    return $self->select("select count(*) from _views")->[0][0];
}

sub new_view {
    my ($self, $data) = @_;
    my $nviews = $self->view_count;
    my $res;
    if ($nviews >= $VIEW_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded view count limit $VIEW_LIMIT.\n";
    }

    my $name = delete $data->{name} or
        die "No 'name' specified.\n";
    _IDENT($name) or die "Bad view name: ", $Dumper->($name), "\n";

    my $minisql = delete $data->{definition};
    if (!defined $minisql) {
        die "No 'definition' specified.\n";
    }
    _STRING($minisql) or die "Bad definition: ", $Dumper->($minisql), "\n";

    my $desc = delete $data->{description};
    if (defined $desc) {
        _STRING($desc) or die "View description must be a string.\n";
    }

    if (%$data) {
        die "Unknown keys: ", join(" ", keys %$data), "\n";
    }

    my $select = MiniSQL::Select->new;
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
        if (!$self->has_model($model)) {
            die "Model \"$model\" not found.\n";
        }
    }

    my $insert = SQL::Insert
        ->new('_views')
        ->cols( qw<name definition description> )
        ->values( Q($name, $minisql, $desc) );

    return { success => $self->do($insert) ? 1 : 0 };

}

sub DELETE_view {
    my ($self, $bits) = @_;
    my $view = $bits->[1];
    _IDENT($view) or $view eq '~' or
        die "Bad view name: ", $Dumper->($view), "\n";
    if ($view eq '~') {
        return $self->DELETE_view_list;
    }
    if (!$self->has_view($view)) {
        die "View \"$view\" not found.\n";
    }
    my $sql = "delete from _views where name = " . Q($view);
    return { success => $self->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_view_list {
    my ($self, $bits) = @_;
    my $sql = "truncate _views;";
    return { success => $self->do($sql) >= 0 ? 1 : 0 };
}

sub has_view {
    my ($self, $view) = @_;

    _IDENT($view) or die "Bad view name: $view\n";

    my $select = SQL::Select->new('count(name)')
        ->from('_views')
        ->where(name => Q($view))
        ->limit(1);
    return $self->select("$select",)->[0][0];
}

1;

