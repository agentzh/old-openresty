package OpenAPI;

use strict;
use warnings;
use vars qw($Dumper);

sub has_role {
    my ($self, $role) = @_;
    _IDENT($role) or
        die "Bad role name: ", $Dumper->($role), "\n";
    my $select = SQL::Select->new('id')
        ->from('_roles')
        ->where(name => Q($role))
        ->limit(1);
    return $self->select("$select")->[0][0];
}

sub DELETE_role {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    if ($role eq '~') {
        return $self->DELETE_role_list;
    }
    if (!$self->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    my $sql = "delete from _roles where name = ".Q($role);
    return { success => $self->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_access_rule {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    my $role_id = $self->has_role($role);
    if (!$role_id) {
        die "Role \"$role\" not found.\n";
    }
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and $col ne 'id') {
        die "Unknown access rule field: $col\n";
    }
    if ($role eq 'Admin') {
        die "Role \"Admin\" is read only.\n";
    }
    my $sql;
    if ($value eq '~') {
        $sql = "delete from _access_rules where role = $role_id;";
    } elsif ($col eq '~') {
        my $quoted = Q($value);
        $sql = "delete from _access_rules where role = $role_id and (method = $quoted or url = $quoted);";
    } else {
        my $quoted = Q($value);
        $sql = "delete from _access_rules where role = $role_id and $col = $quoted;";
    }
    ### DELETE access rules: $sql
    my $res = $self->do($sql);
    return { success => $res >= 0 ? 1 : 0 };
}

sub GET_access_rule {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    my $role_id = $self->has_role($role);
    ### $bits
    if (!$role_id) {
        die "Role \"$role\" not found.\n";
    }
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and $col ne 'id') {
        die "Unknown access rule field: $col\n";
    }

    my $sql;
    if ($value eq '~') {
        $sql = "select id,method,url from _access_rules where role = $role_id;";
    } else {
        my $op = $self->{_cgi}->url_param('op') || 'eq';
        $op = $OpMap{$op};
        if ($op eq 'like') {
            $value = "%$value%";
        }
        my $quoted = Q($value);

        if ($col eq '~') {
            $sql = "select id,method,url from _access_rules where role = $role_id and ( method $op $quoted or url $op $quoted);";
        } else {
            $sql = "select id,method,url from _access_rules where role = $role_id and $col $op $quoted;";
        }
    }
    ### $sql
    my $res = $self->select($sql, { use_hash => 1 });
    $res ||= [];
    return $res;
}

sub POST_access_rule {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    my $role_id = $self->has_role($role);
    if (!$role_id) {
        die "Role \"$role\" not found.\n";
    }
    my $rows_affected = 0;
    my ($success, $last_insert_id);
    my $data = $self->{_req_data};
    if (_HASH($data)) {
        $rows_affected = $self->insert_rule($role_id, $data, 1);
        $success = $rows_affected >= 1 ? 1 : 0;
    } elsif (_ARRAY($data)) {
        my $i = 1;
        for my $elem (@$data) {
            _HASH($elem) or
                die "Access rule is not of hash: ", $Dumper->($elem), "\n";
            $rows_affected += $self->insert_rule($role_id, $elem, $i);
        } continue {
            $i++;
        }
        $success = $rows_affected == @$data ? 1 : 0;
    } else {
        die "Only non-empty hashes or arrays are expected.\n";
    }
    my $last_id = $self->last_insert_id('_access_rules');
    return {
        success => $success,
        rows_affected => $rows_affected >= 0 ? $rows_affected : 0,
        last_row => $last_id ? "/=/role/$role/id/$last_id" : undef,
    };

}

sub insert_rule {
    my ($self, $role, $data, $row) = @_;
    my $id = delete $data->{id};
    if (defined $id) {
        $self->warn("row $row: Column \"id\" ignored.");
    }
    my $method = delete $data->{method} || 'GET';
    _STRING($method) or
        die "row $row: Column \"method\" is not a string: ", $Dumper->($method), "\n";
    if ($method !~ /^(?:GET|POST|PUT|DELETE|HEAD)$/) {
        die "row $row: Unrecognized HTTP method: $method\n";
    }
    my $url = delete $data->{url};
    if (!defined $url) {
        die "row $row: Column \"url\" is missing.\n";
    }
    if (%$data) {
        die "Unrecognized keys found in row $row: ",
            join(" ", keys %$data),
            "\n";
    }
    my $insert = SQL::Insert->new("_access_rules")
        ->cols( qw< role method url > )
        ->values( Q( $role, $method, $url ) );
    return $self->do($insert);
}

sub GET_role_list {
    my ($self, $bits) = @_;
    my $select = SQL::Select->new(
        qw< name description >
    )->from('_roles');
    my $roles = $self->select("$select", { use_hash => 1 });

    $roles ||= [];
    map { $_->{src} = "/=/role/$_->{name}" } @$roles;
    $roles;
}

sub GET_role {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    if ($role eq '~') {
        return $self->GET_role_list;
    }
    my $role_id = $self->has_role($role);
    if (!$role_id) {
        die "Role \"$role\" not found.\n";
    }
    my $select = SQL::Select->new( qw< name description login > )
        ->from('_roles')
        ->where(name => Q($role));

    my $res = $self->select("$select", {use_hash => 1})->[0];
    $res->{columns} = [
        { name => "method", type => "text", label => "HTTP method" },
        { name => "url", type => "text", label => "Resource"}
    ];
    return $res;
}

1;

