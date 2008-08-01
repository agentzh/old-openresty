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

my $json=JSON::XS->new->utf8;

sub POST_action_exec {
    my ($self, $openresty, $bits) = @_;
    my $action = $bits->[1];
    my $params = {
        $bits->[2] => $bits->[3]
    };

    my $meth = "exec_$action";
    if ($self->can($meth)) {
        return $self->$meth($openresty);
    }

    die "Action not found: $action\n";
}

# Remove all existing actions for current user (not including builtin actions)
sub DELETE_action_list
{
	my ($self,$openresty,$bits)=@_;
	my $rv;

	# Try to remove all action parameters
	$rv=$openresty->do("delete from _action_params");
	die 'Failed to remove all action parameters.'
		unless(defined($rv));

	# Try to remove all actions
	$rv=$openresty->do("delete from _actions");
	die 'Failed to remove all actions.'
		unless(defined($rv));

	# All actions except builtin ones were removed successfully
	return {
		success=>1,
		warning=>'Builtin actions are skipped.',
	};
}

# List all existing actions for current user (including builtin actions)
sub GET_action_list
{
	my ($self,$openresty,$bits)=@_;
	my $select=OpenResty::SQL::Select->new(qw/name description/)->from('_actions');
	my $act_lst=$openresty->select("$select",{use_hash=>1});

	# Prepend builtin actions
	unshift(
		@$act_lst,
		{name=>'RunView',description=>'View interpreter'},
		{name=>'RunAction',description=>'Action interpreter'},
	);

	# Add src property for each action entry
	map {$_->{src}="/=/action/$_->{name}"} @$act_lst;

	$act_lst;
}

# List the details of action with the given name, if the given action name is '~' then
# list all existing actions for current user by using GET_action_list.
sub GET_action
{
	my ($self,$openresty,$bits)=@_;
	my $act_name=$bits->[1];

	# If the given action name is wildcard ('~'), then forward the request to GET_action_list
	if($act_name eq '~') {
		return $self->GET_action_list($openresty,$bits);
	}

	# Retrieve the corresponding action information
	my ($select,$res);
	$select=OpenResty::SQL::Select->new(qw/id name description definition/)
				->from('_actions')
				->where(name=>Q($act_name));
	$res=$openresty->select("$select",{use_hash=>1});
	if(!$res || @$res==0) {
		die "Action \"$act_name\" not found.";
	}

	# Retrieve the action parameter information
	my $act_info=$res->[0];
	$select=OpenResty::SQL::Select->new(qw/name type label default_value/)
				->from('_action_params')
				->where(action_id=>Q($act_info->{id}))
				->where(used=>"true");
	$res=$openresty->select("$select",{use_hash=>1});

	# Rename the field "default_value" to "default" and remove field "id"
	map {
		$_->{default}=$_->{default_value};
		delete $_->{default_value};
	} @$res;
	$act_info->{parameters}=$res;
	delete $act_info->{id};

	$act_info;
}

# Execute the given action, possibly with parameters
sub GET_action_exec
{
	my ($self,$openresty,$bits)=@_;
	my $act_name=$bits->[1];
	my $act_param1=$bits->[2];
	my $act_value1=$bits->[3];

	if($act_name eq '~') {
		die "Action name must be specified before executing.";
	}

	my $select=OpenResty::SQL::Select->new(qw/id compiled/)
					->from('_actions')
					->where(name=>Q($act_name));
	my $res=$openresty->select("$select",{use_hash=>1});
	if(!$res || @$res==0) {
		die "Action \"$act_name\" not found.";
	}

	my $act_id=$res->[0]{id};
	my $act_comp=$res->[0]{compiled};
	eval {
		$act_comp=$json->decode($act_comp);
	};
	if($@) {
		die "Failed to load compiled fragments for action \"$act_name\"";
	}
	
	$select=OpenResty::SQL::Select->new(qw/name type default_value/)
					->from('_action_params')
					->where(action_id=>Q($act_id))
					->where(used=>"true");
	$res=$openresty->select("$select",{use_hash=>1});

	# TODO: 增加变量代换

    my @outputs;
    my $i = 0;
    for my $cmd (@$act_comp) {
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

# Delete action with the given name, if the given action name is '~' then
# all existing actions for current user will be deleted by DELETE_action_list.
sub DELETE_action
{
	my ($self,$openresty,$bits)=@_;
	my $act_name=$bits->[1];

	# If the given action name is wildcard ('~'), then forward the request to DELETE_action_list
	if($act_name eq '~') {
		return $self->DELETE_action_list($openresty,$bits);
	}

	my ($select,$res);
	$select=OpenResty::SQL::Select->new(qw/id/)
				->from('_actions')
				->where(name=>Q($act_name));
	$res=$openresty->select("$select",{use_hash=>1});

	# Delete parameters used by the action
	$openresty->do("delete from _action_params where action_id=".Q($res->{id}));
	$openresty->do("delete from _actions where id=".Q($res->{id}));

	return { success=>1 };
}

# Create a named action (no overwrite permitted)
# This routine will do the following things:
# 	1. Make sure there are no actions with the same name yet.
# 	2. Compile the action definition with restyscript.
# 	3. Collect variable names and types from the compiled result,
# 	and check against the action parameter list.
# 	4. 
sub POST_action
{
	my ($self,$openresty,$bits)=@_;
	my $act_name=$bits->[1];

	# Check if the action has been defined to prevent overwriting
	my $select=OpenResty::SQL::Select->new(qw/name/)
				->from('_actions')
				->where(name=>Q($act_name));
	my $act_list=$openresty->select("$select",{use_hash=>1});
	die "Action \"$act_name\" already exists."
		if(@$act_list);

    my $body = $openresty->{_req_data};
	die "Invalid body content, must be a JSON object"
		unless(ref($body) eq 'HASH');
	die "Action definition must be given"
		unless(exists($body->{definition}));

	my $act_def=$body->{definition}; 		# action definition, no default value
	my $act_desc=$body->{description}||''; 	# action description, default to ''
	my $act_params=$body->{parameters}||[]; # action parameter list, default to []
	# Each action parameter is described by a hash containing the following keys:
	# 	name 	- Param name, mandatory. No duplicate name allowed.
	# 	type 	- Param type, mandatory. Must be one of 'literal', 'symbol' or 'keyword'
	# 	label 	- Param label/description, optional. Default to '';
	# 	default - Param default value, optional. Default to null.
	my $act_param_hash={
		map {
			$_->{name}=>{
				type=>$_->{type},
				label=>$_->{label},
				default=>$_->{default},
			}
		} @$act_params
	};

	# Instance a restyscript object to compile action
	my $view=OpenResty::RestyScript->new('action',$act_def);
	my ($frags,$stats)=$view->compile;
	die 'Failed to invoke RestyScript'
	    if (!$frags && !$stats);

    # Check if too many commands are given:
    my $cmds = $frags;
    if (@$cmds > $ACTION_CMD_COUNT_LIMIT) {
        die "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

	my ($var_hash, $canon_cmds)=$self->commands_scanner($openresty, $cmds);
	$self->validate_action_parameters($openresty, $var_hash, $act_param_hash);

	# Verify existences for models used in the action definition
    my @models = @{ $stats->{modelList} };
    $self->validate_model_names($openresty, \@models);

	my $act_comp=$json->encode($canon_cmds);
	my $insert=OpenResty::SQL::Insert->new('_actions')
				->cols(qw/name definition description compiled/)
				->values(Q($act_name,$act_def,$act_desc,$act_comp));
	my $rv=$openresty->do("$insert");
	die "Failed to insert action into backend DB"
		unless(defined($rv));
	
	return { success=>1 };
}

# Verify the types for variables used in action definition against those in parameter list
sub validate_action_parameters
{
	my ($self,$openresty,$cvar_hash,$pvar_hash)=@_;
}

# Walking through the compiled action definition, collect variables and their inferenced types
sub commands_scanner
{
	my ($self,$openresty,$cmds)=@_;

	my %vars;
    my @final_cmds;
    for my $cmd (@$cmds) {
        die "Invalid command: ", Dumper($cmd), "\n" unless ref $cmd;
        if (@$cmd == 1 and ref $cmd->[0]) {   # being a SQL command
            my $cmd = $cmd->[0];
            # Check for variable uses:
            for my $frag (@$cmd) {
                if (ref $frag) {  # being a variable
					my ($var_name,$var_type)=@$frag;

					# Make sure inferenced variable type is consistent
				 	# FIXME: 'unknown' type should be overwritten by concrete types (eg. 'symbol')
					if(exists($vars{$var_name})
						&& $vars{$var_name} ne $var_type) {
						die "Type inference conflict for variable \"$var_name\".";
					}

					# Collect variable and its type
					$vars{$var_name}=$var_type;
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
					my ($var_name,$var_type)=@$frag;

					# Variable type inferenced in SQL action is preferred than in HTTP action
					unless(exists($vars{$var_name})) {
						$vars{$var_name}=$var_type;
					}
                }
            }
            push @bits, $url;

			if($content && @$content) {
				# Check for variable uses in $content:
				for my $frag (@$content) {
					if(ref $frag) { # being a variable
						my ($var_name,$var_type)=@$frag;

						# Variable type inferenced in SQL action is preferred than in HTTP action
						unless(exists($vars{$var_name})) {
							$vars{$var_name}=$var_type;
						}
					}
				}
				
				push @bits,$content;
			}
            push @final_cmds, \@bits;
        }
    }

	return (\%vars,\@final_cmds);
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
    my ($self, $openresty, $models) = @_;
    for my $model (@$models) {
        _IDENT($model) or die "Bad model name: \"$model\"\n";
        if (!$openresty->has_model($model)) {
            die "Model \"$model\" not found.\n";
        }
    }
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

