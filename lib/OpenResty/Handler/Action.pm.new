package OpenResty::Handler::Action;

#use Smart::Comments '####';
use strict;
use warnings;

use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::RestyScript;
use OpenResty::Limits;
use JSON::XS;
use Data::Dumper qw(Dumper);
use OpenResty::QuasiQuote::SQL;

my $json = JSON::XS->new->utf8;

sub POST_action_exec {
    my ( $self, $openresty, $bits ) = @_;
    my $action = $bits->[1];

    # Process builtin actions
    my $meth = "exec_$action";
    if ( $self->can($meth) ) {
        return $self->$meth($openresty);
    }

    # Process user-defined actions
    if ( $action eq '~' ) {
        die "Action name must be specified before executing.";
    }

    my $sql = [:sql|
        select id, compiled
        from _actions
        where name = $action |];
    my $res = $openresty->select( $sql, { use_hash => 1 } );
    if ( !$res || @$res == 0 ) {
        die "Action \"$action\" not found.";
    }

    my $act_id   = $res->[0]{id};
    my $act_comp = $res->[0]{compiled};
    eval { $act_comp = $json->decode($act_comp); };
    if ($@) {
        die "Failed to load compiled fragments for action \"$action\"";
    }

    # Get parameters from POST body content
    my $act_param = $openresty->{_req_data};
    die "Invalid POST body content, must be a JSON object"
        unless ( ref($act_param) eq 'HASH' );

    $sql = [:sql|
        select name, type, default_value
        from _action_params
        where action_id = $act_id and used = true |];
    $res = $openresty->select( $sql, { use_hash => 1 } );

    # Complement parameter values from URL
    my %var_map = ();
    for my $row (@$res) {
        my $val = $act_param->{ $row->{name} }
            || $self->get_param( $openresty, $bits, $row->{name} );
        unless ( defined($val) || defined( $row->{default_value} ) ) {

            # Some parameter were not given
            die
                "Parameter \"$row->{name}\" were not given, and no default value was set";
        }
        $var_map{ $row->{name} } = $val || $row->{default_value};
    }

    # Execute action
    return $self->execute_cmds( $openresty, $act_comp, \%var_map );
}

# Remove all existing actions for current user (not including builtin actions)
sub DELETE_action_list {
    my ( $self, $openresty, $bits ) = @_;
    my $rv;

    # Try to remove all action parameters
    $rv = $openresty->do("delete from _action_params");
    die 'Failed to remove all action parameters.'
        unless ( defined($rv) );

    # Try to remove all actions
    $rv = $openresty->do("delete from _actions");
    die 'Failed to remove all actions.'
        unless ( defined($rv) );

    # All actions except builtin ones were removed successfully
    return {
        success => 1,
        warning => 'Builtin actions are skipped.',
    };
}

# List all existing actions for current user (including builtin actions)
sub GET_action_list {
    my ( $self, $openresty, $bits ) = @_;
    my $sql = [:sql|
        select name, description
        from _actions |];
    my $act_lst = $openresty->select( $sql, { use_hash => 1 } );

    # Prepend builtin actions
    unshift( @$act_lst,
        { name => 'RunView',   description => 'View interpreter' },
        { name => 'RunAction', description => 'Action interpreter' },
    );

    # Add src property for each action entry
    map { $_->{src} = "/=/action/$_->{name}" } @$act_lst;

    $act_lst;
}

# List the details of action with the given name, if the given action name is '~' then
# list all existing actions for current user by using GET_action_list.
sub GET_action {
    my ( $self, $openresty, $bits ) = @_;
    my $act_name = $bits->[1];

# If the given action name is wildcard ('~'), then forward the request to GET_action_list
    if ( $act_name eq '~' ) {
        my $act_lst = $self->GET_action_list( $openresty, $bits );
        return $act_lst;
    }

    # Retrieve the corresponding action information
    my ( $sql, $res );
    $sql = [:sql|
        select id, name, description, definition
        from _actions
        where name = $act_name |];
    $res = $openresty->select( $sql, { use_hash => 1 } );
    if ( !$res || @$res == 0 ) {
        die "Action \"$act_name\" not found.";
    }

    # Retrieve the action parameter information
    my $act_info = $res->[0];
    my $id = $act_info->{id};
    $sql = [:sql|
        select name, type, label, default_value
        from _action_params
        where action_id = $id and used = true |];
    $res = $openresty->select( $sql, { use_hash => 1 } );

    # Rename the field "default_value" to "default" and remove field "id"
    map {
        $_->{default} = $_->{default_value};
        delete $_->{default_value};
    } @$res;
    $act_info->{parameters} = $res;
    delete $act_info->{id};

    $act_info;
}

# Get the parameters given at the 2/3 bit or query string
sub get_param {
    my ( $self, $openresty, $bits, $param_name ) = @_;
    my %var_map = ();
    my $param1  = $bits->[2];
    my $value1  = $bits->[3];
    if ( defined($param1) && $param1 ne '~' && $param1 eq $param_name ) {
        return $value1;
    }
    return $openresty->{_cgi}->url_param($param_name);
}

# Execute the given action, possibly with parameters
sub GET_action_exec {
    my ( $self, $openresty, $bits ) = @_;
    my $act_name = $bits->[1];

    if ( $act_name eq '~' ) {
        die "Action name must be specified before executing.";
    }

    my $sql = [:sql|
        select id, compiled
        from _actions
        where name = $act_name |];
    my $res = $openresty->select( $sql, { use_hash => 1 } );
    if ( !$res || @$res == 0 ) {
        die "Action \"$act_name\" not found.";
    }

    my $act_id   = $res->[0]{id};
    my $act_comp = $res->[0]{compiled};
    eval { $act_comp = $json->decode($act_comp); };
    if ($@) {
        die "Failed to load compiled fragments for action \"$act_name\"";
    }

    $sql = [:sql|
        select name, type, default_value
        from _action_params
        where action_id = $act_id and used = true |];
    $res = $openresty->select( $sql, { use_hash => 1 } );

    my %var_map = ();
    for my $row (@$res) {
        my $val = $self->get_param( $openresty, $bits, $row->{name} );
        unless ( defined($val) || defined( $row->{default_value} ) ) {

            # Some parameter were not given
            die
                "Parameter \"$row->{name}\" were not given, and no default value was set";
        }
        $var_map{ $row->{name} } = $val || $row->{default_value};
    }

    return $self->execute_cmds( $openresty, $act_comp, \%var_map );

}

sub join_with_params {
    my ( $frags, $var_map ) = @_;
    my $result;
    my $ref = ref($frags);

    if ($ref) {
        die "Unknown fragments reference type \"$ref\""
            unless ( $ref eq 'ARRAY' );

        # Given command fragments, proceeding with variable substitution
        for my $frag (@$frags) {
            my $frag_ref = ref($frag);

            if ($frag_ref) {

                # Variable fragment encountered
                die
                    "Parameter fragment reference type should be \"ARRAY\": currently \"$frag_ref\""
                    unless ( $frag_ref eq 'ARRAY' );

                my ( $name, $type ) = @$frag;
                die "Required parameter \"$name\" not assigned"
                    unless ( exists( $var_map->{$name} ) );

                $type = lc($type);
                if ( $type eq 'quoted' ) {

                    # Param should be interpolated as a quoted string
                    $result .= Q( $var_map->{$name} );
                } elsif ( $type eq 'literal' || $type eq 'keyword' ) {

                    # Param should be interpolated as a literal
                    $result .= $var_map->{$name};
                } elsif ( $type eq 'symbol' ) {

                    # Param should be treated like a symbol
                    $result .= QI( $var_map->{$name} );
                } else {

          # Unrecognized param type, coerced to interpolate as a quoted string
                    $result .= Q( $var_map->{$name} );
                }

            } else {

                # Literal fragment encountered
                $result .= $frag;
            }
        }
    } else {

        # Given a solid string, no more works to do
        $result = $frags;
    }

    return $result;
}

sub execute_cmds {
    my ( $self, $openresty, $cmds, $var_map ) = @_;
    my @outputs;
    my $i = 0;

    for my $cmd (@$cmds) {
        $i++;
        if ( !ref( $cmd->[0] ) ) {    # being an HTTP method
            my ( $http_meth, $url, $content ) = @$cmd;

            # Proceeds variable value substitutions
            $url     = join_with_params( $url, $var_map );
            $content = join_with_params( $url, $var_map );

  # DO NOT permit cross-domain HTTP method!!!
  #            if ($url !~ m{^/=/}) {
  #                die "Error in command $i: url does not start by \"/=/\"\n";
  #            }

            local %ENV;
            $ENV{REQUEST_URI}    = $url;
            $ENV{REQUEST_METHOD} = $http_meth;
            my $cgi = new_mocked_cgi( $url, $content );
            my $call_level = $openresty->call_level;
            $call_level++;
            my $account = $openresty->current_user;
            my $res
                = OpenResty::Dispatcher->process_request( $cgi, $call_level,
                $account );
            push @outputs, $res;

        } else {    # being a SQL method, $cmd->[0] is the fragments list
            my $pg_sql = join_with_params( $cmd->[0], $var_map );

            if ( substr( $pg_sql, 0, 6 ) eq 'select' ) {
                my $res = $openresty->select( $pg_sql,
                    { use_hash => 1, read_only => 1 } );
                push @outputs, $res;
            } else {

                # XXX FIXME
                # we should use anonymous roles here in the future:
                my $retval = $openresty->do($pg_sql);
                push @outputs, { success => 1, rows_affected => $retval + 0 };
            }
        }
    }
    return \@outputs;
}

# Delete action with the given name, if the given action name is '~' then
# all existing actions for current user will be deleted by DELETE_action_list.
sub DELETE_action {
    my ( $self, $openresty, $bits ) = @_;
    my $act_name = $bits->[1];

# If the given action name is wildcard ('~'), then forward the request to DELETE_action_list
    if ( $act_name eq '~' ) {
        return $self->DELETE_action_list( $openresty, $bits );
    }

    my ( $sql, $res );
    $sql = [:sql|
        select id
        from _actions
        where name = $act_name |];
    $res = $openresty->select( $sql, { use_hash => 1 } );

    # Delete parameters used by the action
    $openresty->do(
        "delete from _action_params where action_id=" . Q( $res->{id} ) );
    $openresty->do( "delete from _actions where id=" . Q( $res->{id} ) );

    return { success => 1 };
}

# Create a named action (no overwrite permitted)
# This routine will do the following things:
#     1. Make sure there are no actions with the same name yet.
#     2. Compile the action definition with restyscript.
#     3. Collect variable names and types from the compiled result,
#     and check against the action parameter list.
#     4.
sub POST_action {
    my ( $self, $openresty, $bits ) = @_;

    my $body = $openresty->{_req_data};
    die "Invalid body content, must be a JSON object"
        unless ( ref($body) eq 'HASH' );
    die "Action definition must be given"
        unless ( exists( $body->{definition} ) );

    my $act_name = ( $bits->[1] eq '~' ) ? $body->{name} : $bits->[1];
    my $act_def  = $body->{definition};  # action definition, no default value
    my $act_desc = $body->{description}; # action description, default to ''
    my $act_params = $body->{parameters}
        || [];    # action parameter list, default to []

    # Make sure action name was given
    die "Action name should be specified in URL or body content."
        unless ($act_name);

    # Check if the action has been defined to prevent overwriting
    my $sql = [:sql|
        select name
        from _actions
        where name = $act_name |];
    my $act_list = $openresty->select( $sql, { use_hash => 1 } );
    die "Action \"$act_name\" already exists."
        if (@$act_list);

    # Only array reference type allowed for parameter list
    die "Invalid \"parameters\" list: $act_params"
        unless ( ref($act_params) eq 'ARRAY' );

# Each action parameter is described by a hash containing the following keys:
#     name     - Param name, mandatory. No duplicate name allowed.
#     type     - Param type, mandatory. Must be one of 'literal', 'symbol' or 'keyword'
#     label     - Param label/description, optional. Default to '';
#     default - Param default value, optional. Default to null.
    my $act_param_hash = {
        map {
            die "Missing parameter name."
                unless ( defined( $_->{name} ) );
            die "Missing \"type\" for parameter \"$_->{name}\"."
                unless ( defined( $_->{type} ) );
            die "Invalid \"type\" for parameter \"$_->{name}\": "
                . $json->encode( $_->{type} )
                unless ( !ref( $_->{type} )
                && $_->{type} =~ /^(?:symbol|literal|keyword)$/i );

            $_->{name} => {
                type    => $_->{type},
                label   => $_->{label},
                default => $_->{default},
                }
            } @$act_params
    };

    # Instance a restyscript object to compile action
    my $view = OpenResty::RestyScript->new( 'action', $act_def );
    my ( $frags, $stats ) = $view->compile;
    die 'Failed to invoke RestyScript'
        if ( !$frags && !$stats );

    # Check if too many commands are given:
    my $cmds = $frags;
    if ( @$cmds > $ACTION_CMD_COUNT_LIMIT ) {
        die
            "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

    my ( $var_map, $canon_cmds )
        = $self->commands_scanner( $openresty, $cmds );
    $self->validate_action_parameters( $openresty, $var_map,
        $act_param_hash );

    # Verify existences for models used in the action definition
    my @models = @{ $stats->{modelList} };
    $self->validate_model_names( $openresty, \@models );

    # Insert action definition into backend
    my $act_comp = $json->encode($canon_cmds);
    $sql = [:sql|
        insert into _actions (name, definition, description, compiled)
        values($act_name, $act_def, $act_desc, $act_comp) |];
    my $rv = $openresty->do($sql);
    die "Failed to insert action into backend DB"
        unless ( defined($rv) );
    my $act_id = $openresty->last_insert_id('_actions');

    # Insert action parameters into backend
    for my $param_name ( keys(%$act_param_hash) ) {
        my $param = $act_param_hash->{$param_name};
        my $type = $param->{type};
        my $label = $param->{label};
        my $default = $param->{default};
        my $used = $param->{used} ? 'true' : 'false';
        my $sql = [:sql|
            insert into _action_params (name, type, label, default_value, used, action_id)
            values ($param_name, $type, $label, $default, $used, $act_id) |];
        $rv = $openresty->do($sql);
        die
            "Failed to insert action parameter \"$param_name\" into backend DB"
            unless ( defined($rv) );
    }

    return { success => 1 };
}

# Verify the types for variables used in action definition against those in parameter list
sub validate_action_parameters {
    my ( $self, $openresty, $cmd_var_hash, $param_var_hash ) = @_;

    for my $var_name ( keys(%$cmd_var_hash) ) {
        die
            "Parameter \"$var_name\" used in the action definition is not defined in the \"parameters\" list."
            unless ( exists( $param_var_hash->{$var_name} ) );
        die
            "Invalid \"type\" for parameter \"$var_name\". (It's used as a $cmd_var_hash->{$var_name} in the action definition.)"
            unless ( $cmd_var_hash->{$var_name} eq 'unknown'
            || $cmd_var_hash->{$var_name} eq
            $param_var_hash->{$var_name}{type} );

        # TODO: perform type checks
        $param_var_hash->{$var_name}{used} = 1;
    }
}

# Walking through the compiled action definition, collect variables and their inferenced types
sub commands_scanner {
    my ( $self, $openresty, $cmds ) = @_;

    my %vars;
    my @final_cmds;
    for my $cmd (@$cmds) {
        die "Invalid command: ", Dumper($cmd), "\n" unless ref $cmd;
        if ( @$cmd == 1 and ref( $cmd->[0] ) ) {    # being a SQL command
            my $seq = $cmd->[0];

            # Check for variable uses:
            for my $frag (@$seq) {
                if ( ref $frag ) {                  # being a variable
                    my ( $var_name, $var_type ) = @$frag;

# Make sure inferenced variable type is consistent
# FIXME: 'unknown' type should be overwritten by concrete types (eg. 'symbol')
                    if ( exists( $vars{$var_name} )
                        && $vars{$var_name} ne $var_type )
                    {
                        die
                            "Type inference conflict for variable \"$var_name\".";
                    }

                    # Collect variable and its type
                    $vars{$var_name} = $var_type;
                }
            }
            #### SQL: $cmd->[0]
      # We preserve a nested array ref here to distinguish SQL and HTTP method
            push @final_cmds, $cmd;
        } else {    # being an HTTP command
            my ( $http_meth, $url, $content ) = @$cmd;
            if ( $http_meth ne 'POST' and $http_meth ne 'PUT' and $content ) {
                die "Content part not allowed for $http_meth\n";
            }
            my @bits = $http_meth;

            # Check for variable uses in $url:
            for my $fr (@$url) {
                if ( ref($fr) ) {    # being a variable
                    my ( $vname, $vtype ) = @$fr;

     # Variable type inferenced in SQL action is preferred than in HTTP action
                    unless ( exists( $vars{$vname} ) ) {
                        $vars{$vname} = $vtype;
                    }
                }
            }
            push @bits, $url;

            if ( $content && @$content ) {

                # Check for variable uses in $content:
                for my $frag (@$content) {
                    if ( ref $frag ) {    # being a variable
                        my ( $var_name, $var_type ) = @$frag;

     # Variable type inferenced in SQL action is preferred than in HTTP action
                        unless ( exists( $vars{$var_name} ) ) {
                            $vars{$var_name} = $var_type;
                        }
                    }
                }

                push @bits, $content;
            }
            push @final_cmds, \@bits;
        }
    }

    return ( \%vars, \@final_cmds );
}

sub exec_RunView {
    my ( $self, $openresty ) = @_;

    my $sql = $openresty->{_req_data};
    ### Action sql: $sql
    if ( length $sql > $VIEW_MAX_LEN ) {    # more than 10 KB
        die "SQL input too large (must be under 5 KB)\n";
    }

    _STRING($sql)
        or die "Restyscript source must be an non-empty literal string: ",
        $OpenResty::Dumper->($sql), "\n";

    #warn "SQL 1: $sql\n";

    my $view = OpenResty::RestyScript->new( 'view', $sql );
    my ( $frags, $stats ) = $view->compile;
    ### $frags
    ### $stats
    if ( !$frags && !$stats ) { die "Failed to invoke RunView\n" }

    # Check if variables are used:
    for my $frag (@$frags) {
        if ( ref $frag ) {
            die "Variables not allowed in the input to RunView: $frag->[0]\n";
        }
    }

    my @models = @{ $stats->{modelList} };
    $self->validate_model_names( $openresty, \@models );
    my $pg_sql = $frags->[0];

    $openresty->select( $pg_sql, { use_hash => 1, read_only => 1 } );
}

sub exec_RunAction {
    my ( $self, $openresty ) = @_;

    my $sql = $openresty->{_req_data};
    ### Action sql: $sql
    if ( length $sql > $ACTION_MAX_LEN ) {    # more than 10 KB
        die "SQL input too large (must be under 5 KB)\n";
    }

    _STRING($sql)
        or die "Restyscript source must be an non-empty literal string: ",
        $OpenResty::Dumper->($sql), "\n";

    #warn "SQL 1: $sql\n";

    my $view = OpenResty::RestyScript->new( 'action', $sql );
    my ( $frags, $stats ) = $view->compile;
    ### $frags
    ### $stats
    if ( !$frags && !$stats ) { die "Failed to invoke RunAction\n" }

    # Check if too many commands are given:
    my $cmds = $frags;
    if ( @$cmds > $ACTION_CMD_COUNT_LIMIT ) {
        die
            "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

    my @final_cmds;
    for my $cmd (@$cmds) {
        die "Invalid command: ", Dumper($cmd), "\n" unless ref $cmd;
        if ( @$cmd == 1 and ref $cmd->[0] ) {    # being a SQL command
            my $cmd = $cmd->[0];

            # Check for variable uses:
            for my $frag (@$cmd) {
                if ( ref $frag ) {               # being a variable
                    die
                        "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }
            #### SQL: $cmd->[0]
            push @final_cmds, $cmd->[0];
        } else {    # being an HTTP command
            my ( $http_meth, $url, $content ) = @$cmd;
            if ( $http_meth ne 'POST' and $http_meth ne 'PUT' and $content ) {
                die "Content part not allowed for $http_meth\n";
            }
            my @bits = $http_meth;

            # Check for variable uses in $url:
            for my $frag (@$url) {
                if ( ref $frag ) {    # being a variable
                    die
                        "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }
            push @bits, $url->[0];

            # Check for variable uses in $url:
            for my $frag (@$url) {
                if ( ref $frag ) {    # being a variable
                    die
                        "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }

            push @bits, $content->[0] if $content && @$content;
            push @final_cmds, \@bits;
        }
    }

    my @models = @{ $stats->{modelList} };
    $self->validate_model_names( $openresty, \@models );

    my @outputs;
    my $i = 0;
    for my $cmd (@final_cmds) {
        $i++;
        if ( ref $cmd ) {    # being an HTTP method
            my ( $http_meth, $url, $content ) = @$cmd;
            if ( $url !~ m{^/=/} ) {
                die "Error in command $i: url does not start by \"/=/\"\n";
            }

            #die "HTTP commands not implemented yet.\n";
            local %ENV;
            $ENV{REQUEST_URI}    = $url;
            $ENV{REQUEST_METHOD} = $http_meth;
            my $cgi = new_mocked_cgi( $url, $content );
            my $call_level = $openresty->call_level;
            $call_level++;
            my $account = $openresty->current_user;
            my $res
                = OpenResty::Dispatcher->process_request( $cgi, $call_level,
                $account );
            push @outputs, $res;
        } else {
            my $pg_sql = $cmd;
            if ( substr( $pg_sql, 0, 6 ) eq 'select' ) {
                my $res = $openresty->select( $pg_sql,
                    { use_hash => 1, read_only => 1 } );
                push @outputs, $res;
            } else {

                # XXX FIXME
                # we should use anonymous roles here in the future:
                my $retval = $openresty->do($pg_sql);
                push @outputs, { success => 1, rows_affected => $retval + 0 };
            }
        }
    }
    return \@outputs;
}

sub validate_model_names {
    my ( $self, $openresty, $models ) = @_;
    for my $model (@$models) {
        _IDENT($model) or die "Bad model name: \"$model\"\n";
        if ( !$openresty->has_model($model) ) {
            die "Model \"$model\" not found.\n";
        }
    }
}

# Modify a existing action property (rise error when the dest action didn't exist)
sub PUT_action {
    my ( $self, $openresty, $bits ) = @_;
    my $act_name = $bits->[1];
    if ( $act_name eq '~' ) {
        die "Action name must be specified before executing.";
    }

    # Make sure the given action already existed
    my $sql = [:sql|
        select id, compiled
        from _actions
        where name = $act_name |];
    my $res = $openresty->select( $sql, { use_hash => 1 } );
    if ( !$res || @$res == 0 ) {
        die "Action \"$act_name\" not found.";
    }

    my $body = $openresty->{_req_data};
    die "Invalid PUT body content, must be a JSON object"
        unless ( ref($body) eq 'HASH' );

# TODO: PUT更改action的定义时需要注意：
# 1. 更改action的name时需要检测是否存在已经与目标name同名的action，若有则失败;
# 2. 更改action的description时可以直接更改，没有需要检测的地方;
# 3. 更改action的definition时需要检测其是否能通过编译、编译后片段所需的参数
# 是否已经存在、参数类型是否相符，当所需参数之前尚不存在或类型不同时则失败，
# 否则就更新definition和compiled字段，并根据变量使用情况对应更改参数的used字段;
# 4. 更改action的parameters时，需要检测新参数列表是否包含了原action definition所需
# 的变量，若没有完全包含则失败，否则就更新参数变量并根据使用情况修改变量的used
# 字段。
    die "Not completed yet.";
}

1;
__END__

=head1 NAME

OpenResty::Handler::Action - The action handler for OpenResty

=head1 SYNOPSIS

=head1 DESCRIPTION

This OpenResty handler class implements the Action API, i.e., the C</=/action/*> stuff.

=head1 METHODS

=head1 AUTHORS

chaoslawful (王晓哲) C<< <chaoslawful at gmail dot com> >>,
Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Handler::Model>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::View>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

