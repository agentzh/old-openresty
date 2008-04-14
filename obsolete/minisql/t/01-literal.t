use strict;
use warnings;

use t::miniSQL;

# string

test 'string', qq/'a'/, {
    'single_quoted_string' => 'a'
};
test 'string', qq/"a"/, {
    'double_quoted_string' => 'a'
};
test 'string', qq/'a''a'/, {
    'single_quoted_string' => 'a\'a'
};
test 'string', qq/"a""a"/, {
    'double_quoted_string' => 'a"a'
};
test 'string', qq/'''a'''/, {
    'single_quoted_string' => '\'a\''
};
test 'string', qq/"""a"""/, {
    'double_quoted_string' => '"a"'
};
test 'string', qq/'a''b''c'/, {
    'single_quoted_string' => 'a\'b\'c'
};
test 'string', qq/"a""b""c"/, {
    'double_quoted_string' => 'a"b"c'
};

# number

test 'number', qq/1/, {
    'integer' => '1'
};
test 'number', qq/123456/, {
    'integer' => '123456'
};
test 'number', qq/-123456/, {
    'integer' => '-123456'
};
test 'number', qq/+123456/, {
    'integer' => '+123456'
};
test 'number', qq/1.2/, {
    'exact_float' => '1.2'
};
test 'number', qq/123.456/, {
    'exact_float' => '123.456'
};
test 'number', qq/-123.456/, {
    'exact_float' => '-123.456'
};
test 'number', qq/.123456/, {
    'exact_float' => '.123456'
};
test 'number', qq/-.123456/, {
    'exact_float' => '-.123456'
};
test 'number', qq/1e2/, {
    'approximate_float' => '1e2'
};
test 'number', qq/123e456/, {
    'approximate_float' => '123e456'
};
test 'number', qq/123E456/, {
    'approximate_float' => '123E456'
};
test 'number', qq/-123e456/, {
    'approximate_float' => '-123e456'
};
test 'number', qq/1.23e456/, {
    'approximate_float' => '1.23e456'
};
test 'number', qq/-12.3e456/, {
    'approximate_float' => '-12.3e456'
};
test 'number', qq/-.123e-456/, {
    'approximate_float' => '-.123e-456'
};

# literal
test 'literal', '-.1e2', {
    number => rule('number', '-.1e2')->()
};
test 'literal', q/'''b'''/, {
    string => rule('string', q/'''b'''/)->()
};











