package OpenResty::Limits;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $MODEL_LIMIT
    $VIEW_LIMIT
    $FEED_LIMIT
    $ROLE_LIMIT
    $ACTION_LIMIT
    $ACTION_PARAM_LIMIT
    $COLUMN_LIMIT
    $RECORD_LIMIT
    $INSERT_LIMIT
    $POST_LEN_LIMIT
    $MAX_SELECT_LIMIT
    $PASSWORD_MIN_LEN
    $VIEW_MAX_LEN
    $ACTION_MAX_LEN
    $ACTION_CMD_COUNT_LIMIT
    $ACTION_REC_DEPTH_LIMIT
);

our $MODEL_LIMIT = 40;
our $VIEW_LIMIT = 100;
our $FEED_LIMIT = 100;
our $ROLE_LIMIT = 100;
our $COLUMN_LIMIT = 40;
our $ACTION_LIMIT = 40;
our $ACTION_PARAM_LIMIT = 100;
our $INSERT_LIMIT = 20;
our $RECORD_LIMIT = 200;
our $POST_LEN_LIMIT = 1_000_000; # 1 MB
our $MAX_SELECT_LIMIT = 500;
our $PASSWORD_MIN_LEN = 6;
our $VIEW_MAX_LEN = 5_000; # 5 KB
our $ACTION_MAX_LEN = 5_000; # 5 KB
our $ACTION_CMD_COUNT_LIMIT = 5;
our $ACTION_REC_DEPTH_LIMIT = 3;

1;
__END__

=head1 NAME

OpenResty::Limits - Various contraints used in the OpenResty server

=head1 SYNOPSIS

    use OpenResty::Limits;

    print join("\n",
        $MODEL_LIMIT,
        $VIEW_LIMIT,
        $FEED_LIMIT,
        $ROLE_LIMIT,
        $COLUMN_LIMIT,
        $RECORD_LIMIT,
        $INSERT_LIMIT,
        $POST_LEN_LIMIT,
        $MAX_SELECT_LIMIT,
        $PASSWORD_MIN_LEN,
        $VIEW_MAX_LEN,
        $ACTION_MAX_LEN,
        $ACTION_CMD_COUNT_LIMIT,
        $ACTION_REC_DEPTH_LIMIT,
    );

=head1 DESCRIPTION

This module defines various constants which limits the resources each OpenResty account could use, like the number of different objects (models, rows, views, and  etc.).

These constants are not truly constants. Some of them could be overridden by some config options specified in F<etc/site_openresty.conf>. So different servers may have (very) different limitations.

=head1 VARIABLES

=over

=item C<$MODEL_LIMIT>

Model count limit in an account, default 40.

Controlled by config file option C<frontend.model_limit>.

=item C<$VIEW_LIMIT>

View count limit in an account, default 100.

=item C<$FEED_LIMIT>

Feed count limit in an account, default 100.

=item C<$ROLE_LIMIT>

Role count limit in an account, default 100.

=item C<$COLUMN_LIMIT>

Column count limit in a model, default 40.

Controlled by config file option C<frontend.column_limit>.

=item C<$RECORD_LIMIT>

Row count limit in a model, default 200.

Controlled by config file option C<frontend.row_limit>.

=item C<$INSERT_LIMIT>

Maximal number of rows inserted in a single POST request, default 20.

Controlled by config file option C<frontend.bulk_insert_limit>.

=item C<$POST_LEN_LIMIT>

Content length limit for a POST/PUT request, default 1_000_000 (1 MB).

Controlled by config file option C<frontend.post_len_limit>.

=item C<$MAX_SELECT_LIMIT>

Maximal number of rows returned by a unlimited query, default 200.

=item C<$PASSWORD_MIN_LEN>

Minimum length for the password of a role, default 6 chars.

=item C<$VIEW_MAX_LEN>

The maximal length of a view definition, default 5_000 (5 KB).

=item C<$ACTION_MAX_LEN>

The maximal length of an action definition, default 5_000 (5 KB).

=item C<$ACTION_CMD_COUNT_LIMIT>

Maximal number of commands in a single action's definition, default 5

=item C<$ACTION_REC_DEPTH_LIMIT>

The maximal depth of recursive action calls, default 3.

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Config>, L<OpenResty>, L<OpenResty::Spec::Overview>.

