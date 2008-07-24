package OpenResty::Limits;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $MODEL_LIMIT
    $VIEW_LIMIT
    $FEED_LIMIT
    $ROLE_LIMIT
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

OpenResty::Limits - OpenResty backend for the PostgreSQL PL/Proxy-based cluster databases

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

These constants are not truly constants. Some of them could be overriden by some config options specified in F<etc/site_openresty.conf>.

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty>, L<OpenResty::Spec::Overview>.

