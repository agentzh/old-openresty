package OpenResty::Limits;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $MODEL_LIMIT
    $VIEW_LIMIT
    $ROLE_LIMIT
    $COLUMN_LIMIT
    $RECORD_LIMIT
    $INSERT_LIMIT
    $POST_LEN_LIMIT
    $MAX_SELECT_LIMIT
    $PASSWORD_MIN_LEN
);

our $MODEL_LIMIT = 40;
our $VIEW_LIMIT = 100;
our $ROLE_LIMIT = 100;
our $COLUMN_LIMIT = 40;
our $INSERT_LIMIT = 20;
our $RECORD_LIMIT = 200;
our $POST_LEN_LIMIT = 1_000_000; # 1 MB
our $MAX_SELECT_LIMIT = 500;
our $PASSWORD_MIN_LEN = 6;

1;
