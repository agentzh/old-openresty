package OpenResty::Handler::Role;

#use Smart::Comments '####';
use strict;
use warnings;

use Params::Util qw( _HASH _STRING _ARRAY );
use OpenResty::Util;
use OpenResty::Limits;
use OpenResty::QuasiQuote::SQL;

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('role');

sub level2name {
    qw< role_list role access_rule_column access_rule >[$_[-1]];
}

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
    $col = 'prefix' if $col eq 'url';

    my $sql;
    if ($value eq '~') {
        $sql = [:sql|
            select id, method, prefix, segments, array_to_string(applied_to,' ') as applied_to, prohibiting
            from _access
            where role = $role;
        |];
    } else {
        my $op = $openresty->{_cgi}->url_param('op') || 'eq';
        $op = $OpenResty::OpMap{$op};
        if ($op eq 'like') {
            $value = "%$value%";
        }
        #my $quoted = Q($value);

        if ($col eq '~') {
            $sql = [:sql|
                select id, method, prefix, segments, array_to_string(applied_to,' ') as applied_to, prohibiting
                from _access where role = $role and
                    (id::text $kw:op $value or method $kw:op $value or
                     prefix $kw:op $value);
            |];
        } else {
            $sql = [:sql|
                select id, method, prefix, segments, array_to_string(applied_to,' ') as applied_to, prohibiting
                from _access
                where role = $role and $sym:col $kw:op $value;
            |];
        }
    }
    ### $sql
    my $res = $openresty->select($sql, { use_hash => 1 });
    $res ||= [];
    $self->adjust_rules($res);
    return $res;
}

sub adjust_rules {
    my ($self, $rules) = @_;
    for my $rule (@$rules) {
        my $prefix = delete $rule->{prefix};
        my $segments = delete $rule->{segments};
        my @prefix_segs = split /\//, $prefix;
        $rule->{url} = '/=' . ($prefix ? '/' : '') .
            $prefix . ('/~' x ($segments - @prefix_segs));
        my $prohibit = $rule->{prohibiting};
        if ($prohibit && $prohibit eq 'f') {
            # XXX to work around a bug in PgFarm's JSON emitter
            $rule->{prohibiting} = JSON::XS::false;
        } elsif ($prohibit) {
            $rule->{prohibiting} = JSON::XS::true;
        } else {
            $rule->{prohibiting} = JSON::XS::false;
        }
    }
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
    if ($col ne '~' and $col ne 'method' and $col ne 'url' and
                        $col ne 'applied_to' and $col ne 'id') {
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
        if ($col eq 'url') {
            $val =~ s/^\/=\/+//;
            my @bits = split /\/+/, $val;
            (my $prefix = $val) =~ s/(?:\/~)+$//g;
            $prefix = '' if $prefix eq '~';
            my $segs = @bits;
            $update->set(prefix => Q($prefix));
            $update->set(segments => Q($segs));
        } elsif ($col eq 'applied_to') {
            if ($val !~ /^[\d|\.|\/|\s]+$/) {
                die "the acl column applied_to: $applied_to's format must be cidr type seperated by space.";
            }
            $val =~ s/\s+/,/g;
            $update->set(applied_to => Q("{$val}"));
        } else {
            $update->set(QI($col) => Q($val));
        }
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
                "(id::text $op $quoted or method $op $quoted or prefix $op $quoted)"
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
    my $applied_to = delete $data->{applied_to} || '0.0.0.0/0';
    if ($applied_to !~ /^[\d|\.|\/|\s]+$/) {
        die "the acl column applied_to: $applied_to's format must be cidr type seperated by space.";
    }
    $applied_to =~ s/\s+/,/g;
    $applied_to = "{$applied_to}";
    my $prohibiting = delete $data->{prohibiting} ? 'true' : 'false';
    if ($url !~ s/^\/=\/+//) {
        die "URL must be lead by \"/=/\".\n";
    }
    if (%$data) {
        die "Unrecognized keys found in row $row: ",
            join(" ", keys %$data),
            "\n";
    }
    my @bits = split /\/+/, $url;
    (my $prefix = $url) =~ s/(?:\/~)+$//g;
    $prefix = '' if $prefix eq '~';
    my $segs = @bits;
    my $sql = [:sql|
        insert into _access (role, method, prefix, segments, applied_to, prohibiting)
        values ($role, $method, $prefix, $segs, $applied_to, $prohibiting) |];
    return $openresty->do($sql);
}

sub GET_role_list {
    my ($self, $openresty, $bits) = @_;
    my $sql = [:sql|
        select name, description
        from _roles
        order by id |];
    my $roles = $openresty->select($sql, { use_hash => 1 });

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
    my $sql = [:sql|
        select name, description, login
        from _roles
        where name = $role |];

    my $res = $openresty->select($sql, {use_hash => 1})->[0];
    $res->{columns} = [
        { name => "method", type => "text", label => "HTTP method" },
        { name => "url", type => "text", label => "Resource"},
        { name => "applied_to", type => "text", label => "Applied_to"},
        { name => "prohibiting", type => "boolean", label => "Prohibiting"}
    ];
    return $res;
}

sub DELETE_role_list {
    my ($self, $openresty, $bits) = @_;

    my $sql = [:sql|
        select name
        from _roles |];
    my $roles = $openresty->select($sql);
    my $user = $openresty->current_user;
    $roles ||= [];
    for my $role (@$roles) {
        $role = $role->[0];
        next if $role eq 'Admin' or $role eq 'Public';
        #die "Removing cache for role $user.$role...\n";
        $OpenResty::Cache->remove_has_role($user, $role);
    }

    $sql = [:sql|
        delete from _access where role <> 'Admin' and role <> 'Public';
        delete from _roles where name <> 'Admin' and name <> 'Public' |];
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

    if (!$openresty->is_unlimited) {
        my $nroles = $self->role_count($openresty);
        if ($nroles >= $ROLE_LIMIT) {
            die "Exceeded role count limit $ROLE_LIMIT.\n";
        }
    }
    my $res;
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

    my $insert = [:sql|
        insert into _roles(name, description, login, password)
        values($name, $desc, $login, $password) |];

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
        if (length($new_password) < $PASSWORD_MIN_LEN) {
            die "Password too short; at least $PASSWORD_MIN_LEN chars required.\n";
        }

        #check_password($new_password);
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

sub current_user_can {
    my ($self, $openresty, $meth, $bits) = @_;
    my $role = $openresty->{_role};
    my $client_ip = $openresty->{_client_ip};
    return 1 if $role eq 'Admin'; # short cut
    my $url = join '/', @$bits;
    my $segs = @$bits;
    my $sql = [:sql|
        select prohibiting
        from _access
        where role = $role and method = $meth and segments = $segs
            and $url like (prefix || '%') |];
    if ($client_ip && $client_ip ne '127.0.0.1') {
        $sql .= [:sql| and cidr($client_ip) <<= any(applied_to) |];
    }
    $sql .= " order by prohibiting desc limit 1";
    ### $sql
    my $res = $openresty->select($sql);
    if ($res && @$res) {
        my $rule = $res->[0];
        #### $rule
        my $prohibiting = $rule->[0];
        if ($prohibiting) {
            # XXX to work around a bug in PgFarm's JSON emitter
            if ($prohibiting eq 'f') { return 1; }
            return undef;
        }
        return 1;
    }
    return undef;
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

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Model>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

