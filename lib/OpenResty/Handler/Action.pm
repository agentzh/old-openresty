package OpenResty::Handler::Action;

#use Smart::Comments '####';
use strict;
use warnings;

use OpenResty::Util;
use Params::Util qw( _HASH _STRING );
use OpenResty::RestyScript;
use OpenResty::Limits;
use Data::Dumper qw(Dumper);

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
Agent Zhang (agentzh) C<< <agentzh@gmail.com >>

=head1 SEE ALSO

L<OpenResty::Handler::Model>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::View>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

