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

# Create a named action (no overwrite permitted)
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
	my $data;

	# Decode POST body
	eval {
		$data=$json->decode($body);
	};
	die 'Invalid body data, must be a valid JSON object'
		if($@);
	die 'Action definition must be given'
		unless(exists($data->{definition}));

	my $act_def=$data->{definition};
	my $act_desc=$data->{description}||'';

	# Instance a action definition compiler
	my $view=OpenResty::RestyScript->new('action',$act_def);
	my ($frags,$stats)=$view->compile;
	die 'Failed to invoke RunAction'
	    if (!$frags && !$stats);

    # Check if too many commands are given:
    my $cmds = $frags;
    if (@$cmds > $ACTION_CMD_COUNT_LIMIT) {
        die "Too many commands in the action (should be no more than $ACTION_CMD_COUNT_LIMIT)\n";
    }

	# Passing through the compiled action definition, collect variables and their inferenced types
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

	# Verify the types for variables used in action definition against those in parameter list
	my @var_names=keys %vars;
	if(@var_names) {
		my $act_params=$data->{parameters}||[];
		# TODO:
	}

	# Verify existences for models used in the action definition
    my @models = @{ $stats->{modelList} };
    $self->validate_model_names($openresty, \@models);
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

