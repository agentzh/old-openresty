package OpenAPI;

#use Smart::Comments;
use strict;
use warnings;

use vars qw($Dumper);

sub has_role {
    my ($self, $role) = @_;
    _IDENT($role) or
        die "Bad role name: ", $Dumper->($role), "\n";
    my $select = SQL::Select->new('count(*)')
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
    if ($role eq 'Admin' or $role eq 'Public') {
        die "Role \"$role\" reserved.\n";
    }
    if (!$self->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    my $sql = "delete from _access_rules where role = ".Q($role).";\n".
        "delete from _roles where name = ".Q($role);
    return { success => $self->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_access_rule {
    my ($self, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    if (!$self->has_role($role)) {
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
        $sql = "delete from _access_rules where role = '$role';";
    } elsif ($col eq '~') {
        my $quoted = Q($value);
        $sql = "delete from _access_rules where role = '$role' and (id::text = $quoted or method = $quoted or url = $quoted);";
    } else {
        my $quoted = Q($value);
        $sql = "delete from _access_rules where role = '$role' and $col = $quoted;";
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
    ### $bits
    if (!$self->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and $col ne 'id') {
        die "Unknown access rule field: $col\n";
    }

    my $sql;
    if ($value eq '~') {
        $sql = "select id,method,url from _access_rules where role = '$role';";
    } else {
        my $op = $self->{_cgi}->url_param('op') || 'eq';
        $op = $OpMap{$op};
        if ($op eq 'like') {
            $value = "%$value%";
        }
        my $quoted = Q($value);

        if ($col eq '~') {
            $sql = "select id,method,url from _access_rules where role = '$role' and ( id::text $op $quoted or method $op $quoted or url $op $quoted);";
        } else {
            $sql = "select id,method,url from _access_rules where role = '$role' and $col $op $quoted;";
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
    if (!$self->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    my $rows_affected = 0;
    my ($success, $last_insert_id);
    my $data = $self->{_req_data};
    if (_HASH($data)) {
        $rows_affected = $self->insert_rule($role, $data, 1);
        $success = $rows_affected >= 1 ? 1 : 0;
    } elsif (_ARRAY($data)) {
        my $i = 1;
        for my $elem (@$data) {
            _HASH($elem) or
                die "Access rule is not of hash: ", $Dumper->($elem), "\n";
            $rows_affected += $self->insert_rule($role, $elem, $i);
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
    if ($url !~ /^\/=\//) {
        die "URL must be lead by \"/=/\".\n";
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

sub DELETE_role_list {
    my ($self, $bits) = @_;
    my $sql = "delete from _access_rules where role <> 'Admin' and role <> 'Public';\n".
        "delete from _roles where name <> 'Admin' and name <> 'Public'";
    $self->warning("Predefined roles skipped.");
    return { success => $self->do($sql) >= 0 ? 1 : 0 };
}

sub current_user_can {
    my ($self, $meth, $bits) = @_;
    my @urls = $bits;
    my $role = $self->{_role};
    my $max_i = @$bits - 1;
    while ($max_i >= 1) {
        my @last_bits = @{ $urls[-1] };
        if ($last_bits[$max_i] ne '~') {
            $last_bits[$max_i] = '~';
            push @urls, \@last_bits;
        }
    } continue { $max_i-- }
    map { $_ = '/=/' . join '/', @$_ } @urls;
    my $or_clause = join ' or ', map { "url = ".Q($_) } @urls;
    my $sql = "select count(*) from _access_rules where role = ".
        Q($role) . " and method = " . Q($meth) . " and ($or_clause);";
    ### $sql
    my $res = $self->select($sql);
    return do { $res->[0][0] };
}

sub POST_role {
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The role schema must be a HASH.\n";
    my $role = $bits->[1];

    my $name;
    if ($role eq '~') {
        $role = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $role) {
        $self->warning("name \"$name\" in POST content ignored.");
    }

    $data->{name} = $role;
    return $self->new_role($data);
}

sub role_count {
    my $self = shift;
    return $self->select("select count(*) from _roles")->[0][0];
}

sub new_role {
    my ($self, $data) = @_;
    my $nroles = $self->role_count;
    my $res;
    if ($nroles >= $ROLE_LIMIT) {
        die "Exceeded role count limit $ROLE_LIMIT.\n";
    }

    my $name = delete $data->{name} or
        die "No 'name' specified.\n";
    _IDENT($name) or die "Bad role name: ", $Dumper->($name), "\n";

    my $desc = delete $data->{description};
    if (!defined $desc) {
        die "Field 'description' is missing.\n";
    }
    _STRING($desc) or die "Role description must be a string.\n";

    my $login = delete $data->{login};
    if (!defined $login) {
        die "No 'login' field specified.\n";
    }
    _STRING($login) or die "Bad 'login' value: ", $Dumper->($login), "\n";

    if ($login !~ /^(?:password|captcha|anonymous)$/) {
        die "Unknown login method: $login\n";
    }

    my $password = delete $data->{password};
    if (defined $password and $login ne 'password') {
        $self->warning("Field 'password' ignored.");
    }

    if ($login eq 'password') {
        if (!defined $password) {
            die "No password given when 'login' is 'password'.\n";
        } elsif (length($password) < $PASSWORD_MIN_LEN) {
            die "Password too short; at least $PASSWORD_MIN_LEN chars required.\n";
        }
    }

    if (%$data) {
        die "Unknown keys: ", join(" ", keys %$data), "\n";
    }

    my $insert = SQL::Insert
        ->new('_roles')
        ->cols( qw<name description login password> )
        ->values( Q($name, $desc, $login, $password) );

    return { success => $self->do($insert) ? 1 : 0 };
}

1;

