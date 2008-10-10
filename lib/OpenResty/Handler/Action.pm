package OpenResty::Handler::Action;

#use Smart::Comments '####';
use strict;
use warnings;

use LWP::UserAgent;
use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::RestyScript;
use OpenResty::Limits;
use JSON::XS ();
use LWP::UserAgent ();
use Data::Dumper qw(Dumper);
use OpenResty::QuasiQuote::SQL;
use OpenResty::QuasiQuote::Validator;
use List::Util qw(first);

use base 'OpenResty::Handler::Base';

__PACKAGE__->register('action');

sub level2name {
    qw< action_list action action_param action_exec  >[$_[-1]]
}

my $ua = LWP::UserAgent->new;
$ua->timeout(2);

sub POST_action_exec {
    my ( $self, $openresty, $bits ) = @_;
    my $action = $bits->[1];

    # Process builtin actions
    my $meth = "exec_$action";
    if ( $self->can($meth) ) {
        return $self->$meth($openresty);
    }

    # Get parameters from POST body content
    my $args = $openresty->{_req_data};
    die "Invalid POST body content, must be a JSON object"
        unless _HASH($args);
    if ($bits->[-1] ne '~' && $bits->[-2] ne '~') {
        $args->{$bits->[-2]} = $bits->[-1];
    }
    my $url_params = $openresty->{_url_params};
    $args = Hash::Merge::merge($args, $url_params);
    ##### $args

    # Complement parameter values from URL
    # Execute action
    return $self->exec_user_action( $openresty, $action, $args );
}

# Remove all existing actions for current user (not including builtin actions)
sub DELETE_action_list {
    my ( $self, $openresty, $bits ) = @_;
    my $user = $openresty->current_user;
    my $res = $self->get_actions($openresty);
    if ($res && @$res) {
        my @actions = map { @$_ } @$res;

        for my $action (@actions) {
            $OpenResty::Cache->remove_has_action($user, $action);
        }

        $openresty->do('truncate _actions cascade;');
    }
    return { success => 1, warning => 'Builtin actions were skipped.' };
}

sub drop_action {
    my ($self, $openresty, $action) = @_;
    my $user = $openresty->current_user;
    $OpenResty::Cache->remove_has_action($user, $action);
    return [:sql|
        delete from _actions where name = $action;
    |];
}

sub get_actions {
    my ($self, $openresty) = @_;
    my $sql = [:sql| select name from _actions |];
    return $openresty->select($sql);
}

# List all existing actions for current user (including builtin actions)
sub GET_action_list {
    my ( $self, $openresty, $bits ) = @_;
    my $sql = [:sql|
        select name, description
        from _actions |];
    my $actions = $openresty->select( $sql, { use_hash => 1 } );

    # Prepend builtin actions
    unshift @$actions,
        { name => 'RunView',   description => 'View interpreter' },
        { name => 'RunAction', description => 'Action interpreter' };

    # Add src property for each action entry
    map { $_->{src} = "/=/action/$_->{name}" } @$actions;
    $actions;
}

# List the details of action with the given name, if the given action name is '~' then
# list all existing actions for current user by using GET_action_list.
sub GET_action {
    my ( $self, $openresty, $bits ) = @_;
    my $action = $bits->[1];

# If the given action name is wildcard ('~'), then forward the request to GET_action_list
    if ( $action eq '~' ) {
        my $act_lst = $self->GET_action_list( $openresty, $bits );
        return $act_lst;
    }

    my $compiled = $self->has_action($openresty, $action);
    if (!$compiled) {
        die "Action \"$action\" not found.\n";
    }
    $compiled = $OpenResty::JsonXs->decode($compiled);
    my $params = $compiled->[0];

    # Retrieve the corresponding action information
    my ( $sql, $res );
    $sql = [:sql|
        select name, description, definition
        from _actions
        where name = $action |];
    $res = $openresty->select( $sql, { use_hash => 1 } );
    my $rt = $res->[0];

    my @params = map { delete $_->{used}; $_ } values %$params;
    # Retrieve the action parameter information
    # Rename the field "default_value" to "default" and remove field "id"
    $rt->{parameters} = \@params;
    $rt;
}

# Execute the given action, possibly with parameters
sub GET_action_exec {
    my ( $self, $openresty, $bits ) = @_;
    my $args = $openresty->{_url_params};
    if ($bits->[2] ne '~' && $bits->[3] ne '~') {
        $args->{$bits->[2]} = $bits->[3];
    }
    #### $args
    return $self->exec_user_action( $openresty, $bits->[1], $args );

}

sub join_frags_with_args {
    my ( $frags, $params, $args, $quote_literal) = @_;
    my $result;
    my $ref = ref $frags;
    $quote_literal ||= \&Q;

    if ($ref) {
        die "Unknown fragments reference type \"$ref\""
            unless ( $ref eq 'ARRAY' );

        # Given command fragments, proceeding with variable substitution
        for my $frag (@$frags) {
            my $frag_ref = ref $frag;

            if ($frag_ref) {

                # Variable fragment encountered
                die
                    "Parameter fragment reference type should be \"ARRAY\": currently \"$frag_ref\""
                    unless $frag_ref eq 'ARRAY';

                my $name = $frag->[0];
                my $type = $frag->[1];
                if ($type eq 'unknown') {
                    $type = $params->{$name}{type};
                }
                die "Required parameter \"$name\" not assigned"
                    unless ( exists( $args->{$name} ) );

                $type = lc($type);
                if ( $type eq 'quoted' ) {

                    # Param should be interpolated as a quoted string
                    $result .= $args->{$name};
                } elsif ( $type eq 'literal' ) {

                    # Param should be interpolated as a literal
                    $result .= $quote_literal->($args->{$name});
                } elsif ( $type eq 'symbol' ) {

                    # Param should be treated like a symbol
                    if ($args->{$name} !~ /^[A-Za-z]\w*$/) {
                        die "Bad value for parameter \"$name\".\n";
                    }
                    $result .= QI( $args->{$name} );
                } elsif ( $type eq 'keyword') {
                    if ($args->{$name} !~ /^(asc|desc)$/) {
                        die "Invalid valud for parameter \"$name\".\n";
                    }
                    $result .= $args->{$name};
                } else {

          # Unrecognized param type, coerced to interpolate as a quoted string
                    # XXX croak?
                    $result .= $quote_literal->( $args->{$name} );
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
    #### $result

    return $result;
}

sub has_action {
    my ($self, $openresty, $action) = @_;
    my $user = $openresty->current_user;

    if (my $compiled = $OpenResty::Cache->get_has_action($user, $action)) {
        #warn "has model cache HIT\n";
        return $compiled;
    }
    my $sql = [:sql|
        select compiled
        from _actions
        where name = $action
        limit 1;
    |];
    my $ret;
    eval { $ret = $openresty->select($sql)->[0][0]; };
    if ($ret) { $OpenResty::Cache->set_has_action($user, $action, $ret) }
    return $ret;
}

sub exec_user_action {
    my ( $self, $openresty, $action, $args ) = @_;
    my $i = 0;

    if ($action eq '~' ) {
        die "Action name must be specified before executing.";
    }

    my $compiled = $self->has_action($openresty, $action);
    if (!$compiled) {
        die "Action \"$action\" not found.\n";
    }
    eval { $compiled = $OpenResty::JsonXs->decode($compiled); };
    if ($@) {
        die "Failed to load compiled fragments for action \"$action\"\n";
    }
    my ($params, $canon_cmds) = @$compiled;

    #### $params
    my @missed_args;
    while (my ($name, $param) = each %$params) {
        next unless $param->{used};
        my $val = $args->{ $name };
        if ( !defined $val && !defined $param->{default_value} ) {
            # Some parameter were not given
            push @missed_args, $name if $param->{used};
        }
        # XXX a bug here...
        if (!defined $val) { $val = $param->{default_value}; }
        $args->{ $name } = $val;
    }
    if (@missed_args) {
        die "Arguments required: @missed_args\n";
    }

    my $account = $openresty->current_user;
    #### %OpenResty::AllowForwarding
    my $allow_forwarding = $OpenResty::AllowForwarding{$account};
    #### $canon_cmds
    #warn "Allow: $allow_forwarding";
    my @outputs;
    for my $cmd (@$canon_cmds) {
        $i++;
        if ( !ref( $cmd->[0] ) ) {    # being an HTTP method
            my ( $http_meth, $url, $content ) = @$cmd;

            # Proceeds variable value substitutions
            $url     = join_frags_with_args( $url, $params, $args );
            $content = join_frags_with_args(
                $content, $params, $args,
                \&OpenResty::json_encode,
            );
            #### $url
            #### $content

            if ($url =~ m{^/=/}) {
                local %ENV;
                $ENV{REQUEST_URI}    = $url;
                $ENV{REQUEST_METHOD} = $http_meth;
                (my $query = $url) =~ s/(.*?\?)//g;
                #$query .= '&';
                #warn "Query: $query\n";
                $ENV{QUERY_STRING} = $query;

                my $cgi = new_mocked_cgi( $url, $content );
                my $call_level = $openresty->call_level;
                $call_level++;
                push @outputs,
                    OpenResty::Dispatcher->process_request(
                        $cgi, $call_level, $account
                    );
            } else { # absolute requests
                if ( ! $allow_forwarding ) {
                    die "Error in command $i: url does not start with \"/=/\"\n";
                }
                push @outputs, do_http_request($http_meth, \$url, \$content);
            }
        } else {    # being a SQL method, $cmd->[0] is the fragments list
            my $pg_sql = join_frags_with_args( $cmd->[0], $params, $args );

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

sub do_http_request {
    my ($meth, $rurl, $rcontent) = @_;
    #no strict 'subs';
    #### $meth
    my $url = $$rurl;
    #### $url

    my $req = HTTP::Request->new($meth);
    $req->header('Content-Type' => 'text/plain');
    $req->header('Accept', '*/*');
    $req->url($$rurl);

    my $res = $ua->request($req);
        # judge result and next action based on $response_code
    if ($res->is_success) {
        my $content = $res->content;
        my $type = $res->header('Content-Type');
        if ($type !~ /^text\//) {
            return {
                success => 0, error => 'Text response expected.',
            };
        }

        my $data;
        eval {
            $data = $OpenResty::JsonXs->decode($content);
        };
        if ($@) {
            return $content;
        } else {
            return $data;
        }
    } else {
        return {
            success => 0, error => $res->status_line,
        };
    }
}

# Delete action with the given name, if the given action name is '~' then
# all existing actions for current user will be deleted by DELETE_action_list.
sub DELETE_action {
    my ( $self, $openresty, $bits ) = @_;
    my $action = $bits->[1];
    if ( $action eq '~' ) {
        return $self->DELETE_action_list( $openresty, $bits );
    }
    if (!$self->has_action($openresty, $action)) {
        die "Action \"$action\" not found.\n";
    }

    # Delete parameters used by the action
    #die "HERE!";
    my $sql = $self->drop_action($openresty, $action);
    $openresty->do($sql);
    return { success => 1 };
}

sub action_count {
    my ($self, $openresty) = @_;
    return $openresty->select("select count(*) from _actions")->[0][0];
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
    my $data = _HASH($openresty->{_req_data}) or
        die "The action schema must be a HASH.\n";
    my $action = $bits->[1];

    my $name;
    if ($action eq '~') {
        $action = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $action) {
        $openresty->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $action;
    return $self->new_action($openresty, $data);
}

sub new_action {
    my ($self, $openresty, $data) = @_;
    my $action_count = $self->action_count($openresty);
    if ($action_count >= $ACTION_LIMIT) {
        die "Exceeded action count limit: $ACTION_LIMIT.\n";
    }

    my ($action, $desc, $params, $def);
    [:validator|
        $data ~~
        {
            name: IDENT :required :to($action),
            description: STRING :nonempty :to($desc),
            parameters: [
                {
                    name: IDENT :required,
                    label: STRING :nonempty,
                    type: STRING :nonempty :required
                        :allowed('keyword', 'literal', 'symbol'),
                    default_value: STRING,
                }
            ] :to($params),
            definition: STRING :nonempty :required :to($def),
        } :required :nonempty
    |]
    $params ||= [];
    if (@$params > $ACTION_PARAM_LIMIT) {
        die "Exceeded model column count limit: $ACTION_LIMIT.\n";
    }

    if ($self->has_action($openresty, $action)) {
        die "Action \"$action\" already exists.\n";
    }

# Each action parameter is described by a hash containing the following keys:
#     name     - Param name, mandatory. No duplicate name allowed.
#     type     - Param type, mandatory. Must be one of 'literal', 'symbol' or 'keyword'
#     label     - Param label/description, optional. Default to '';
#     default - Param default value, optional. Default to null.
    $params = { map { $_->{name} => $_ } @$params };

    # Instance a restyscript object to compile action
    my $restyc = OpenResty::RestyScript->new( 'action', $def );
    my ( $frags, $stats ) = $restyc->compile;
    if ( !$frags && !$stats ) {
        die "Failed to invoke RestyScript.\n"
    }

    # Check if too many commands are given:
    my $cmds = $frags;
    if ( @$cmds > $ACTION_CMD_COUNT_LIMIT ) {
        die
            "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

    # $vars is the vars actually used in the action definition
    my ( $vars, $canon_cmds )
        = $self->compile_frags( $openresty, $cmds );
    $self->process_params_with_vars( $openresty, $vars, $params );

    # Verify existences for models used in the action definition
    my @models = @{ $stats->{modelList} };
    $self->validate_model_names( $openresty, \@models );

    for my $name ( keys %$params ) {
        my $param = $params->{$name};
        my $type = $param->{type};
        my $default = $param->{default_value};
        check_default($default, $type, $name) if defined $default;
    }

    # Insert action definition into backend
    my $compiled = OpenResty::json_encode([ $params, $canon_cmds ]);
    my $sql = [:sql|
        insert into _actions (name, definition, description, compiled)
        values($action, $def, $desc, $compiled); |];
    my $rv = $openresty->do($sql);
    die "Failed to insert action into backend DB"
        unless ( defined($rv) );
    my $id = $openresty->last_insert_id('_actions');

    # Insert action parameters into backend
    $sql = '';
    for my $name ( keys %$params ) {
        my $param = $params->{$name};
        my $type = $param->{type};
        my $label = $param->{label};
        my $default = $param->{default_value};
        my $used = $param->{used} ? 'true' : 'false';
        $sql .= [:sql|
            insert into _action_params (name, type, label, default_value, used, action_id)
            values ($name, $type, $label, $default, $kw:used, $id); |];
    }
    $rv = $openresty->do($sql);
    #warn $rv;
    return { success => 1 };
}

sub check_default {
    my ($default, $type, $name) = @_;
    #warn "Type: $type\n";
    #warn "Default: $type\n";
    if ($type eq 'symbol' && $default !~ /^[A-Za-z]\w*$/) {
        die "Bad default value for parameter \"$name\" of type $type.\n";
    }
    if ($type eq 'keyword' && $default !~ /^(?:desc|asc)$/) {
        die "Bad default value for parameter \"$name\" of type $type.\n";
    }
}

# Verify the types for variables used in action definition against those in parameter list
sub process_params_with_vars {
    my ( $self, $openresty, $vars, $params ) = @_;

    my %used;
    for my $name ( keys(%$vars) ) {
        if (!exists $params->{$name}) {
            die "Parameter \"$name\" used in the action definition is not defined in the \"parameters\" list.\n"
        }

        if ($vars->{$name} ne 'quoted') {
            if ($vars->{$name} eq 'unknown' &&
                    $params->{$name}{type} eq 'keyword') {
                die "Parameter \"$name\" is not used as a \"keyword\" in the action definition.\n";
            }
            if ($vars->{$name} ne 'unknown' &&
                    $vars->{$name} ne $params->{$name}{type}) {
                die "Invalid \"type\" for parameter \"$name\". (It's used as a $vars->{$name} in the action definition.)\n";
            }
            #if ($vars->{$name} eq 'unknown') {
            #$vars->{$name} = $params->{$name}{type};
            #warn "HERE!!!!!!!!!!! unknown!!!!";
            #}
        }

        # TODO: perform type checks
        $used{$name} = 1;
    }
    while (my ($name, $param) = each %$params) {
        if ($used{$name}) {
            $param->{used} = 1;
        } else {
            delete $param->{used};
        }
    }
}

# Walking through the compiled action definition, collect variables and their inferenced types
sub compile_frags {
    my ( $self, $openresty, $cmds ) = @_;

    my %vars;
    my @canon_cmds;
    for my $cmd (@$cmds) {
        die "Invalid command: ", $OpenResty::Dumper->($cmd), "\n" unless ref $cmd;
        if ( @$cmd == 1 and ref $cmd->[0] ) {    # being a SQL command
            my $seq = $cmd->[0];

            # Check for variable uses:
            for my $frag (@$seq) {
                if ( ref $frag ) {                  # being a variable
                    my ( $var_name, $var_type ) = @$frag;

# Make sure inferenced variable type is consistent
# FIXME: 'unknown' type should be overwritten by concrete types (eg. 'symbol')
                    if ( $var_type ne 'unknown' && exists $vars{$var_name}
                        && $vars{$var_name} ne $var_type )
                    {
                        die "Type inference conflict for variable \"$var_name\": $var_type expected.\n";
                    }

                    # Collect variable and its type
                    $vars{$var_name} = $var_type;
                }
            }
            #### SQL: $cmd->[0]
      # We preserve a nested array ref here to distinguish SQL and HTTP method
            push @canon_cmds, $cmd;
        } else {    # being an HTTP command
            my ( $http_meth, $url, $content ) = @$cmd;
            if ( $http_meth ne 'POST' and $http_meth ne 'PUT' and $content ) {
                die "Content part not allowed for $http_meth\n";
            }
            my @bits = $http_meth;

            # Check for variable uses in $url:
            for my $fr (@$url) {
                if ( ref $fr ) {    # being a variable
                    my ( $vname, $vtype ) = @$fr;

     # Variable type inferenced in SQL action is preferred than in HTTP action
                    unless ( exists $vars{$vname} ) {
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
                        unless ( exists $vars{$var_name} ) {
                            $vars{$var_name} = $var_type;
                        }
                    }
                }

                push @bits, $content;
            }
            push @canon_cmds, \@bits;
        }
    }

    return ( \%vars, \@canon_cmds );
}

sub exec_RunView {
    my ($self, $openresty) = @_;

    my $sql = $openresty->{_req_data};
    ### Action sql: $sql
    if (length $sql > $VIEW_MAX_LEN) { # more than 10 KB
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

    # Check if variables are used:
    for my $frag (@$frags) {
        if (ref $frag) {
            die "Variables not allowed in the input to RunView: $frag->[0]\n";
        }
    }

    my @models = @{ $stats->{modelList} };
    $self->validate_model_names($openresty, \@models);
    my $pg_sql = $frags->[0];

    $openresty->select($pg_sql, {use_hash => 1, read_only => 1});
}

sub exec_RunAction {
    my ($self, $openresty) = @_;

    my $sql = $openresty->{_req_data};
    ### Action sql: $sql
    if (length $sql > $ACTION_MAX_LEN) { # more than 10 KB
        die "SQL input too large (must be under 5 KB)\n";
    }

    _STRING($sql) or
        die "Restyscript source must be an non-empty literal string: ", $OpenResty::Dumper->($sql), "\n";
   #warn "SQL 1: $sql\n";

    my $view = OpenResty::RestyScript->new('action', $sql);
    my ($frags, $stats) = $view->compile;
    ### $frags
    ### $stats
    if (!$frags && !$stats) { die "Failed to invoke RunAction\n" }

    # Check if too many commands are given:
    my $cmds = $frags;
    if (@$cmds > $ACTION_CMD_COUNT_LIMIT) {
        die "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

    my @final_cmds;
    for my $cmd (@$cmds) {
        die "Invalid command: ", Dumper($cmd), "\n" unless ref $cmd;
        if (@$cmd == 1 and ref $cmd->[0]) {   # being a SQL command
            my $cmd = $cmd->[0];
            # Check for variable uses:
            for my $frag (@$cmd) {
                if (ref $frag) {  # being a variable
                    die "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }
            #### SQL: $cmd->[0]
            push @final_cmds, $cmd->[0];
        } else { # being an HTTP command
            my ($http_meth, $url, $content) = @$cmd;
            if ($http_meth ne 'POST' and $http_meth ne 'PUT' and $content) {
                die "Content part not allowed for $http_meth\n";
            }
            my @bits = $http_meth;

            # Check for variable uses in $url:
            for my $frag (@$url) {
                if (ref $frag) { # being a variable
                    die "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }
            push @bits, $url->[0];

            # Check for variable uses in $url:
            for my $frag (@$url) {
                if (ref $frag) { # being a variable
                    die "Variable not allowed in the input to RunAction: $frag->[0]\n";
                }
            }

            push @bits, $content->[0] if $content && @$content;
            push @final_cmds, \@bits;
        }
    }

    my @models = @{ $stats->{modelList} };
    $self->validate_model_names($openresty, \@models);

    my @outputs;
    my $i = 0;
    for my $cmd (@final_cmds) {
        $i++;
        if (ref $cmd) { # being an HTTP method
            my ($http_meth, $url, $content) = @$cmd;
            if ($url !~ m{^/=/}) {
                die "Error in command $i: url does not start by \"/=/\"\n";
            }
            #die "HTTP commands not implemented yet.\n";
            local %ENV;
            $ENV{REQUEST_URI} = $url;
            $ENV{REQUEST_METHOD} = $http_meth;
            (my $query = $url) =~ s/(.*?\?)//g;
            $ENV{QUERY_STRING} = $query;
            my $cgi = new_mocked_cgi($url, $content);
            my $call_level = $openresty->call_level;
            $call_level++;
            my $account = $openresty->current_user;
            my $res = OpenResty::Dispatcher->process_request($cgi, $call_level, $account);
            push @outputs, $res;
        } else {
            my $pg_sql = $cmd;
            if (substr($pg_sql, 0, 6) eq 'select') {
                my $res = $openresty->select($pg_sql, {use_hash => 1, read_only => 1});
                push @outputs, $res;
            } else {
                # XXX FIXME
                # we should use anonymous roles here in the future:
                my $retval = $openresty->do($pg_sql);
                push @outputs, {success => 1,rows_affected => $retval+0};
            }
        }
    }
    return \@outputs;
}

sub validate_model_names {
    my ( $self, $openresty, $models ) = @_;
    for my $model (@$models) {
        if ($model =~ /^\$[A-Za-z]\w*$/) {
            die "Parameters cannot be used as model names.\n";
        }
        _IDENT($model) or die "Bad model name: \"$model\"\n";
        if ( !$openresty->has_model($model) ) {
            die "Model \"$model\" not found.\n";
        }
    }
}

# Modify a existing action property (rise error when the dest action didn't exist)
sub PUT_action {
    my ( $self, $openresty, $bits ) = @_;
    my $name = $bits->[1];
    if ( $name eq '~' ) {
        die "Action name must be specified before executing.";
    }

    my $data = $openresty->{_req_data};
    return $self->alter_action($openresty, $name, $data);
}

sub alter_action {
    # Make sure the given action already existed
    my $self = shift;
    my $openresty = $_[0];
    my $action = _IDENT($_[1]) or die "Invalid action name \"$_[1]\".\n";
    my $data = $_[2];
    my $user = $openresty->current_user;
    my $old_compiled = $self->has_action($openresty, $action);
    if (!$old_compiled) {
        die "Action \"$action\" not found.\n";
    }

    my ($new_action, $desc, $def);

    [:validator|
        $data ~~
        {
            name: IDENT :to($new_action),
            description: STRING :nonempty :to($desc),
            definition: STRING :nonempty :to($def),
        } :required :nonempty
    |]

    $OpenResty::Cache->remove_has_action($user, $action);

    my $sql;
    if ($new_action) {
        if ($self->has_action($openresty, $new_action)) {
            die "Action \"$new_action\" already exists.\n";
        }
        $sql .= [:sql|
            update _actions set name=$new_action where name=$action;
        |];
    }
    $new_action ||= $action;
    if ($desc) {
        $sql .= [:sql|
            update _actions
            set description = $desc
            where name = $new_action;
        |];
    }
    if ($def) {
        eval { $old_compiled = $OpenResty::JsonXs->decode($old_compiled) };
        if ($@) { die "Failed to load old compiled action: $@\n"; }
        my $params = $old_compiled->[0];
        my $restyc = OpenResty::RestyScript->new( 'action', $def );
        my ( $frags, $stats ) = $restyc->compile;
        if ( !$frags && !$stats ) {
            die "Failed to invoke RestyScript.\n"
        }

        # Check if too many commands are given:
        my $cmds = $frags;
        if ( @$cmds > $ACTION_CMD_COUNT_LIMIT ) {
            die
                "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
        }

        # $vars is the vars actually used in the action definition
        my ( $vars, $canon_cmds )
            = $self->compile_frags( $openresty, $cmds );
        #### $params
        #### $vars
        $self->process_params_with_vars( $openresty, $vars, $params );

        # Verify existences for models used in the action definition
        my @models = @{ $stats->{modelList} };
        $self->validate_model_names( $openresty, \@models );

        # Insert action definition into backend
        my $compiled = OpenResty::json_encode([ $params, $canon_cmds ]);

        $sql .= [:sql|
            update _actions
            set compiled = $compiled, definition = $def
            where name = $new_action;
        |];

    }
    #warn "SQL: $sql";
    $openresty->do($sql);
    return { success => 1 };
}

sub POST_action_param {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    #warn "ACTION is $action\n";
    my $param = $bits->[2];
    #warn "PARAM is $param\n";
    my $data = _HASH($openresty->{_req_data}) or
        die "Value must be a HASH.\n";

    my $compiled = $self->has_action($openresty, $action);
    if (!$compiled) {
        die "Action \"$action\" not found.\n";
    }
    eval { $compiled = $OpenResty::JsonXs->decode($compiled); };
    if ($@) { die "Failed to load compiled action: $@\n" }
    my $params = $compiled->[0];
    my @param_names = keys %$params;

    if (@param_names >= $ACTION_PARAM_LIMIT) {
        die "Exceeded model column count limit: $ACTION_PARAM_LIMIT.\n";
    }

    my $alias;
    if ($param ne '~') {
        $alias = $data->{name};
        $data->{name} = $param || die "Name for the new action parameter required.\n";
    }

    my ($label, $default, $type);

    my $has_default = exists $data->{default_value};

    [:validator|
        $data ~~
            {
                name: IDENT :required :to($param),
                label: STRING :nonempty :to($label),
                type: STRING :nonempty :required
                    :to($type) :allowed('keyword', 'literal', 'symbol'),
                default_value: STRING :to($default),
            } :required :nonempty
    |]

    my $fst = first { $param eq $_ } @param_names;
    if (defined $fst) {
        die "Parameter \"$param\" already exists in action \"$action\".\n";
    }

    my $user = $openresty->current_user;
    $OpenResty::Cache->remove_has_action($user, $action);

    $params->{$param} = {
        name => $param,
        type => $type,
        label => $label,
    };

    if ($has_default) {
        $default = $data->{default_value};
        if (defined $default) {
            #warn "DEFAULT: $default\n";
            check_default($default, $type, $param);
        }
        $params->{$param}{default_value} = $default;
    }

    $compiled = OpenResty::json_encode($compiled);

    my $id = $openresty->select(
        [:sql| select id from _actions where name = $action |]
    )->[0][0];
    my $sql = [:sql|
        insert into _action_params (name, type, label, default_value, used, action_id)
        values ($param, $type, $label, $default, false, $id);
        update _actions set compiled = $compiled where name = $action;
    |];
    $openresty->do($sql);

    return { success => 1,
             src => "/=/model/$action/$param",
             warning => "Parameter name \"$alias\" ignored."
     } if $alias && $alias ne $param;
    return { success => 1, src => "/=/model/$action/$param" };

}

sub PUT_action_param {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $param = $bits->[2];
    my $data = $openresty->{_req_data};
    my $user = $openresty->current_user;

    my $compiled = $self->has_action($openresty, $action);
    if (!$compiled) {
        die "Action \"$action\" not found.\n";
    }
    $compiled = $OpenResty::JsonXs->decode($compiled);
    my ($params, $frags) = @$compiled;

    my ($new_param, $type, $label, $default);

    my $has_default = exists $data->{default_value};

    [:validator|
        $data ~~ {
            name: IDENT :to($new_param),
            label: STRING :nonempty :to($label),
            type: STRING :nonempty :to($type)
                :allowed('keyword', 'literal', 'symbol'),
            default_value: STRING,
        } :required :nonempty
    |]

    $OpenResty::Cache->remove_has_action($user, $action);

    my $update_meta = OpenResty::SQL::Update->new('_action_params');
    if ($new_param) {
        #$new_col = $new_col);
        $update_meta->set(name => Q($new_param));
        $params->{$new_param} = delete $params->{$param};
    } else {
        $new_param = $param;
    }

    # XXX TODO: check default_value versus the type

    #my $old_type = $params->{$new_param}{type};
    #my $old_default = $params->{$new_param}{default};
    if ($type) {
        #die "Changing column type is not supported.\n";
        $params->{$new_param} ||= {};
        #my $old_type = $params->{$new_param}{type};
        #warn "Old type: $old_type\n";
        #if ($params->{$new_param}{used} && $old_type && $old_type ne $type) {
        #die "Parameter \"$new_param\" is not used as a \"$type\" in the action definition.\n";
        #}
        $update_meta->set(type => Q($type));
        $params->{$new_param}{type} = $type;
        my ( $vars, $new_frags )
            = $self->compile_frags( $openresty, $frags );
        $self->process_params_with_vars( $openresty, $vars, $params );
    }

    if (defined $label) {
        $update_meta->set(label => Q($label));
        $params->{$new_param}{label} = $label;
    }

    $type ||= $params->{$new_param}{type};
    if ($has_default) {
        my $default = $data->{default_value};
        if (defined $default) {
            #warn "DEFAULT: $default\n";
            #warn "TYPE: $type\n";
            $update_meta->set(default_value => Q($default));
            check_default($default, $type, $new_param);
        } else {
            $update_meta->set(default_value => 'null');
        }
        $params->{$new_param}{default_value} = $default;
    }

    my $id = $openresty->select(
        [:sql| select id from _actions where name = $action |]
    )->[0][0];
    $update_meta->where(action_id => Q($id))
        ->where(name => Q($param));

    # XXX TODO: add support for updating column's uniqueness

    $compiled = OpenResty::json_encode($compiled);
    my $sql = $update_meta . [:sql|
        update _actions set compiled = $compiled where id = $id
    |];
    #warn "SQL:: $sql\n";

    my $res = $openresty->do($sql);

    return { success => 1 };

}

sub GET_action_param {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $param = $bits->[2];

    if (!$self->has_action($openresty, $action)) {
        die "Action \"$action \" not found.\n";
    }

    my $id = $openresty->select(
        [:sql| select id from _actions where name = $action |]
    )->[0][0];

    if ($param eq '~') {
        my $sql = [:sql|
            select name, type, label, default_value
            from _action_params
            where action_id = $id
            order by id |];
        my $list = $openresty->select($sql, { use_hash => 1 });
        if (!$list or !ref $list) { $list = []; }

        return $list;
    } else {
        my $sql = [:sql|
            select name, type, label, default_value
            from _action_params
            where name = $param and action_id = $id
            order by id |];
        my $res = $openresty->select($sql, { use_hash => 1 });
        if (!$res or !@$res) {
            die "Action parameter \"$param\" not found.\n";
        }
        return $res->[0];
    }
}

sub DELETE_action_param {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $param = $bits->[2];

    my $compiled = $self->has_action($openresty, $action);
    if (!$compiled) {
        die "Action \"$action \" not found.\n";
    }

    $compiled = $OpenResty::JsonXs->decode($compiled);
    my $params = $compiled->[0];
    #my @param_names = keys %$params;

    my $id = $openresty->select(
        [:sql| select id from _actions where name = $action |]
    )->[0][0];

    my $sql = '';
    if ($param eq '~') {
        while (my ($key, $val) = each %$params) {
            if ($val->{used}) {
                die "Failed to remove parameter \"$key\": it's used in the definition.\n";
            }
        }
        %$params = ();

        $sql .= [:sql|
            delete from _action_params
            where action_id = $id; |];
    } else {
        if ($params->{$param}{used}) {
            die "Failed to remove parameter \"$param\": it's used in the definition.\n";
        }
        $params = delete $params->{$param};
        $sql = [:sql|
            delete from _action_params
            where action_id=$id and name=$param; |];
    }
    my $user = $openresty->current_user;
    $OpenResty::Cache->remove_has_action($user, $action);

    $compiled = OpenResty::json_encode($compiled);

    my $res = $openresty->do($sql . [:sql|
        update _actions set compiled = $compiled where name = $action
    |]);
    return { success => 1 };

}

# TODO: PUT更改action的定义时需要注意：
# 1. 更改action的name时需要检测是否存在已经与目标name同名的action，若有则失败;
# 2. 更改action的description时可以直接更改，没有需要检测的地方;
# 3. 更改action的definition时需要检测其是否能通过编译、编译后片段所需的参数
# 是否已经存在、参数类型是否相符，当所需参数之前尚不存在或类型不同时则失败，
# 否则就更新definition和compiled字段，并根据变量使用情况对应更改参数的used字段;
# 4. 更改action的parameters时，需要检测新参数列表是否包含了原action definition所需
# 的变量，若没有完全包含则失败，否则就更新参数变量并根据使用情况修改变量的used
# 字段。

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

