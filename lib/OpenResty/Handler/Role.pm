package OpenResty::Handler::Role;

#use Smart::Comments;
use strict;
use warnings;

use Params::Util qw( _HASH _STRING _ARRAY );
use OpenResty::Util;
use OpenResty::Limits;

sub DELETE_role {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    if ($role eq '~') {
        return $self->DELETE_role_list($openresty);
    }
    if ($role eq 'Admin' or $role eq 'Public') {
        die "Role \"$role\" reserved.\n";
    }
    if (!$openresty->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    my $user = $openresty->current_user;
    $OpenResty::Cache->remove_has_role($user, $role);
    my $sql = "delete from _access where role = ".Q($role).";\n".
        "delete from _roles where name = ".Q($role);
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

sub DELETE_access_rule {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    if (!$openresty->has_role($role)) {
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
        $sql = "delete from _access where role = '$role';";
    } elsif ($col eq '~') {
        my $quoted = Q($value);
        $sql = "delete from _access where role = '$role' and (id::text = $quoted or method = $quoted or url = $quoted);";
    } else {
        my $quoted = Q($value);
        $sql = "delete from _access where role = '$role' and $col = $quoted;";
    }
    ### DELETE access rules: $sql
    my $res = $openresty->do($sql);
    return { success => $res >= 0 ? 1 : 0 };
}

sub GET_access_rule {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    ### $bits
    if (!$openresty->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and $col ne 'id') {
        die "Unknown access rule field: $col\n";
    }

    my $sql;
    if ($value eq '~') {
        $sql = "select id,method,url from _access where role = '$role';";
    } else {
        my $op = $openresty->{_cgi}->url_param('op') || 'eq';
        $op = $OpenResty::OpMap{$op};
        if ($op eq 'like') {
            $value = "%$value%";
        }
        my $quoted = Q($value);

        if ($col eq '~') {
            $sql = "select id,method,url from _access where role = '$role' and ( id::text $op $quoted or method $op $quoted or url $op $quoted);";
        } else {
            $sql = "select id,method,url from _access where role = '$role' and $col $op $quoted;";
        }
    }
    ### $sql
    my $res = $openresty->select($sql, { use_hash => 1 });
    $res ||= [];
    return $res;
}

sub PUT_access_rule {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    ### $bits
    if (!$openresty->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    if ($role eq 'Admin') {
        die "Role \"Admin\" is read only.\n";
    }
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and $col ne 'id') {
        die "Unknown access rule field: $col\n";
    }

    my $update = OpenResty::SQL::Update->new('_access');
    my $data = $openresty->{_req_data};
    _HASH($data) or die "Only non-empty HASH expected.\n";
    while (my ($key, $val) = each %$data) {
        my $col = $key;
        if (lc($col) eq 'id') {
            die "Column \"id\" reserved.\n";
        }
        $update->set($col => Q($val));
    }

    if ($value eq '~') {
        $update->where(role => Q($role));
    } else {
        my $op = $openresty->{_cgi}->url_param('op') || 'eq';
        $op = $OpenResty::OpMap{$op};
        if ($op eq 'like') {
            $value = "%$value%";
        }
        my $quoted = Q($value);

        if ($col eq '~') {
            $update->where(
                'role', '=', Q($role),
                "(id::text $op $quoted or method $op $quoted or url $op $quoted)"
            );

        } else {
            $update->where(role => Q($role))
                   ->where($col => $op => $quoted);
        }
    }
    ### Put rule SQL: "$update"
    my $res = $openresty->do("$update");
    return { success => $res >= 0 ? 1 : 0 };

}

sub POST_access_rule {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    my $col = $bits->[2];
    my $value = $bits->[3];
    if (!$openresty->has_role($role)) {
        die "Role \"$role\" not found.\n";
    }
    my $rows_affected = 0;
    my ($success, $last_insert_id);
    my $data = $openresty->{_req_data};
    if (_HASH($data)) {
        $rows_affected = $self->insert_rule($openresty, $role, $data, 1);
        $success = $rows_affected >= 1 ? 1 : 0;
    } elsif (_ARRAY($data)) {
        my $i = 1;
        for my $elem (@$data) {
            _HASH($elem) or
                die "Access rule is not of hash: ", $OpenResty::Dumper->($elem), "\n";
            $rows_affected += $self->insert_rule($openresty, $role, $elem, $i);
        } continue {
            $i++;
        }
        $success = $rows_affected == @$data ? 1 : 0;
    } else {
        die "Only non-empty hashes or arrays are expected.\n";
    }
    my $last_id = $openresty->last_insert_id('_access');
    return {
        success => $success,
        rows_affected => $rows_affected >= 0 ? $rows_affected : 0,
        last_row => $last_id ? "/=/role/$role/id/$last_id" : undef,
    };
}

sub insert_rule {
    my ($self, $openresty, $role, $data, $row) = @_;
    my $id = delete $data->{id};
    if (defined $id) {
        $openresty->warn("row $row: Column \"id\" ignored.");
    }
    my $method = delete $data->{method} || 'GET';
    _STRING($method) or
        die "row $row: Column \"method\" is not a string: ", $OpenResty::Dumper->($method), "\n";
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
    my $insert = OpenResty::SQL::Insert->new("_access")
        ->cols( qw< role method url > )
        ->values( Q( $role, $method, $url ) );
    return $openresty->do("$insert");
}

sub GET_role_list {
    my ($self, $openresty, $bits) = @_;
    my $select = OpenResty::SQL::Select->new(
        qw< name description >
    )->from('_roles');
    my $roles = $openresty->select("$select", { use_hash => 1 });

    $roles ||= [];
    map { $_->{src} = "/=/role/$_->{name}" } @$roles;
    $roles;
}

sub GET_role {
    my ($self, $openresty, $bits) = @_;
    my $role = $bits->[1];
    if ($role eq '~') {
        return $self->GET_role_list($openresty);
    }
    my $role_id = $openresty->has_role($role);
    if (!$role_id) {
        die "Role \"$role\" not found.\n";
    }
    my $select = OpenResty::SQL::Select->new( qw< name description login > )
        ->from('_roles')
        ->where(name => Q($role));

    my $res = $openresty->select("$select", {use_hash => 1})->[0];
    $res->{columns} = [
        { name => "method", type => "text", label => "HTTP method" },
        { name => "url", type => "text", label => "Resource"}
    ];
    return $res;
}

sub DELETE_role_list {
    my ($self, $openresty, $bits) = @_;

    my $select = OpenResty::SQL::Select->new(
        qw< name description >
    )->from('_roles');
    my $roles = $openresty->select("$select");
    my $user = $openresty->current_user;
    $roles ||= [];
    for my $role (@$roles) {
        $OpenResty::Cache->remove_has_role($user, $role);
    }

    my $sql = "delete from _access where role <> 'Admin' and role <> 'Public';\n".
        "delete from _roles where name <> 'Admin' and name <> 'Public'";
    $openresty->warning("Predefined roles skipped.");
    return { success => $openresty->do($sql) >= 0 ? 1 : 0 };
}

sub POST_role {
    my ($self, $openresty, $bits) = @_;
    my $data = _HASH($openresty->{_req_data}) or
        die "The role schema must be a HASH.\n";
    my $role = $bits->[1];

    my $name;
    if ($role eq '~') {
        $role = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $role) {
        $openresty->warning("name \"$name\" in POST content ignored.");
    }

    $data->{name} = $role;
    return $self->new_role($openresty, $data);
}

sub role_count {
    my ($self, $openresty) = @_;
    return $openresty->select("select count(*) from _roles")->[0][0];
}

sub new_role {
    my ($self, $openresty, $data) = @_;
    my $nroles = $self->role_count($openresty);
    my $res;
    if ($nroles >= $ROLE_LIMIT) {
        die "Exceeded role count limit $ROLE_LIMIT.\n";
    }

    my $name = delete $data->{name} or
        die "No 'name' specified.\n";
    _IDENT($name) or die "Bad role name: ", $OpenResty::Dumper->($name), "\n";
    if ($openresty->has_role($name)) {
        die "Role \"$name\" already exists.\n";
    }

    my $desc = delete $data->{description};
    if (!defined $desc) {
        die "Field 'description' is missing.\n";
    }
    _STRING($desc) or die "Role description must be a string.\n";

    my $login = delete $data->{login};
    if (!defined $login) {
        die "No 'login' field specified.\n";
    }
    _STRING($login) or die "Bad 'login' value: ", $OpenResty::Dumper->($login), "\n";

    if ($login !~ /^(?:password|captcha|anonymous)$/) {
        die "Unknown login method: $login\n";
    }

    my $password = delete $data->{password};
    if (defined $password and $login ne 'password') {
        $openresty->warning("Field 'password' ignored.");
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

    my $insert = OpenResty::SQL::Insert
        ->new('_roles')
        ->cols( qw<name description login password> )
        ->values( Q($name, $desc, $login, $password) );

    return { success => $openresty->do("$insert") ? 1 : 0 };
}

sub PUT_role {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $role = $bits->[1];
    my $data = _HASH($openresty->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    ### $data
    die "Role \"$role\" not found.\n" unless $openresty->has_role($role);
    my $extra_sql = '';

    my $update = OpenResty::SQL::Update->new('_roles');
    $update->where(name => Q($role));

    my $new_name = delete $data->{name};
    if (defined $new_name) {
        _IDENT($new_name) or die "Bad role name: ", $OpenResty::Dumper->($new_name);
        $OpenResty::Cache->remove_has_role($user, $role);
        $update->set( name => Q($new_name) );
        $extra_sql .= 'update _access set role='.Q($new_name).' where role='.Q($role).';';
    }

    my $new_login = delete $data->{login};
    if (defined $new_login) {
        _STRING($new_login) or
            die "Bad login method: ", $OpenResty::Dumper->($new_login), "\n";
        if ($new_login !~ /^(?:password|anonymous|captcha)$/) {
            die "Bad login method: $new_login\n";
        }
        $OpenResty::Cache->remove_has_role($user, $role);
        $update->set(login => Q($new_login));
    }

    my $new_password = delete $data->{password};
    if (defined $new_password) {
        if (defined $new_login && $new_login ne 'password') {
            die "Password given when 'login' is not 'password'.\n";
        }
        _STRING($new_password) or
            die "Bad password: ", $OpenResty::Dumper->($new_password), "\n";
        check_password($new_password);
        $update->set(password => Q($new_password));
    }

    if (defined $new_login and $new_login eq 'password' and !defined $new_password) {
        die "No password given when 'login' is 'password'.\n";
    }

    my $new_desc = delete $data->{description};
    if (defined $new_desc) {
        _STRING($new_desc) or die "Bad role definition: ", $OpenResty::Dumper->($new_desc), "\n";
        $update->set(description => Q($new_desc));
    }
    ### Update SQL: "$update"
    if (%$data) {
        die "Unknown keys in POST data: ", join(' ', keys %$data), "\n";
    }
    my $retval = $openresty->do("$update" . $extra_sql) + 0;
    return { success => $retval >= 0 ? 1 : 0 };
}

1;
__END__

=head1 NAME

OpenResty::Handler::Role - The role handler for OpenResty

=head1 SYNOPSIS

    use OpenResty::Handler::Role;

    $data = OpenResty::Handler::Role->GET_role_list($openresty, \@url_bits);

=head1 DESCRIPTION

This OpenResty handler class implements the Role API, i.e., the C</=/role/*> interface.

=head1 METHODS

=over

=item C< GET_role_list($openresty, \@url_bits) >

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Model>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

