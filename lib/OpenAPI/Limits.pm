package OpenAPI::Limits;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    $MODEL_LIMIT
    $COLUMN_LIMIT
    $RECORD_LIMIT
    $INSERT_LIMIT
    $POST_LEN_LIMIT
    $PUT_LEN_LIMIT
    $MAX_SELECT_LIMIT
);

our $MODEL_LIMIT = 40;
our $COLUMN_LIMIT = 40;
our $INSERT_LIMIT = 20;
our $RECORD_LIMIT = 200; # XXX Should be at least 10_000 for production!
our $POST_LEN_LIMIT = 10_000;
our $PUT_LEN_LIMIT = 10_000;
our $MAX_SELECT_LIMIT = 500;

1;
