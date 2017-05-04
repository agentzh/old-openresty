package OpenResty::Handler::View;

use strict;
use warnings;

#use Smart::Comments;
use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::Limits;
use OpenResty::RestyScript::View;
use OpenResty::Handler::Model;
use OpenResty::QuasiQuote::SQL;

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('view');

sub level2name {
    qw< view_list view view_param view_exec >[$_[-1]]
}

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
    my $sql = [:sql|
        select name, description
        from _views
        order by id |];
    return $openresty->select($sql, { use_hash => 1 });
}

sub get_view_names {
    my ($self, $openresty) = @_;
    my $sql = [:sql|
        select name
        from _views |];
    my $res = $openresty->select($sql);
    ### $res
    if ($res && ref $res && ref $res->[0]) {
        @$res = map { @$_ } @$res;
    }
    $res;
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
    my $sql = [:sql|
        select name, definition, description
        from _views
        where name = $view |];

    return $openresty->select($sql, {use_hash => 1})->[0];
}

sub PUT_view {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $view = $bits->[1];
    my $data = _HASH($openresty->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    ### $view
    ### $data
    die "View \"$view\" not found.\n" unless $openresty->has_view($view);

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
        # XXX check the syntax of the def
        my $restyscript = OpenResty::RestyScript::View->new;
        my $res;
        eval {
            $res = $restyscript->parse(
                $new_def,
                { quote => \&Q, quote_ident => \&QI }
            );
        };
        if ($@) { die "minisql: $@\n"; }
        my @models = @{ $res->{models} };
        foreach my $model (@models){
            next if $model =~ /^\s*$/;
            if (!$openresty->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
        $OpenResty::Cache->remove_view_def($user, $view);

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
    my $user = $openresty->current_user;
    my $select = OpenResty::RestyScript::View->new;
    my $view_def = $OpenResty::Cache->get_view_def($user, $view);
    if (!$view_def) {
        my $sql = "select definition from _views where name = " . Q($view);
        ### laser exec_view: "$sql"
        $view_def = $openresty->select($sql)->[0][0];
        $OpenResty::Cache->set_view_def($user, $view, $view_def);
    }
    my $fix_var = $bits->[2];
    _IDENT($fix_var) or $fix_var eq '~' or die "Bad parameter name: ", $OpenResty::Dumper->($fix_var), "\n";
    my $fix_var_value = $bits->[3];
    my $exists;
    my %vars;

    foreach my $var ($openresty->url_param) {
        $vars{$var} = $openresty->url_param($var) unless $var =~ /^_/;
    }

    if ($fix_var ne '~' and $fix_var_value ne '~') {
        $vars{$fix_var} = $fix_var_value;
    }
    my $role = $openresty->get_role;

    # yup...this part is hacky...we'll remove it once we have views running on the Haskell compiler...
    $view_def =~ s/\$_ACCOUNT\b/Q($user)/seg;
    $view_def =~ s/\$_ROLE\b/Q($role)/seg;
    #warn $view_def;

    my $res;
    eval {
        $res = $select->parse(
            $view_def,
            { quote => \&Q,
              quote_ident => \&QI,
              vars => \%vars },
        );
    };
    if ($@) {
        die "minisql: $@\n";
    }

    my @unbound = @{ $res->{unbound} };
    if (@unbound) {
        die "Parameters required: @unbound\n";
    }
    #warn "view SQL: ", $res->{sql}, "\n";
    return $openresty->select($res->{sql}, { use_hash => 1, read_only => 1 });

}

sub GET_view_exec {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $view = $bits->[1];

    die "View \"$view\" not found.\n" unless $openresty->has_view($view);
    return $self->exec_view($openresty, $view, $bits, $openresty->{_cgi});
}

sub view_count {
    my ($self, $openresty) = @_;
    return $openresty->select("select count(*) from _views")->[0][0];
}

sub new_view {
    my ($self, $openresty, $data) = @_;

    if (!$openresty->is_unlimited) {
        my $nviews = $self->view_count($openresty);
        if ($nviews >= $VIEW_LIMIT) {
            die "Exceeded view count limit $VIEW_LIMIT.\n";
        }
    }

    my $res;
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

    my $sql = [:sql|
        insert into _views (name, definition, description)
        values($name, $minisql, $desc) |];

    return { success => $openresty->do($sql) ? 1 : 0 };

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
    $OpenResty::Cache->remove_view_def($user, $view);
    my $sql = "delete from _views where name = " . Q($view);
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_view_list {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;

    my $views = $self->get_view_names($openresty);
    for my $view (@$views) {
        #warn "View $view...\n";
        $OpenResty::Cache->remove_has_view($user, $view);
        $OpenResty::Cache->remove_view_def($user, $view);
    }
    my $sql = "truncate _views;";
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

1;
__END__

=head1 NAME

OpenResty::Handler::View - The view handler for OpenResty

=head1 SYNOPSIS

=head1 DESCRIPTION

This OpenResty handler class implements the View API, i.e., the C</=/view/*> stuff.

=head1 METHODS

=head1 AUTHORS

Laser Henry (laser) C<< <laserhenry at gmail dot com> >>,
Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>

=head1 SEE ALSO

L<OpenResty::Handler::Model>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

