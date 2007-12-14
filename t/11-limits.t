use t::OpenAPI 'no_plan';
#use Smart::Comments;
use JSON::Syck 'Dump';
use OpenAPI::Limits;
use constant {
    INSERT_LIMIT => 20,
    POST_LEN_LIMIT => 10_000,
    PUT_LEN_LIMIT => 10_000,
};

my $host = $t::OpenAPI::host;
my $res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

for (1..$MODEL_LIMIT + 2) {
    my $model_name = 'Foo'.$_;
    my $url = '/=/model/'.$model_name;
    ### $url
    my $body = '{description:"blah",columns:[{name:"title",label:"title"}]}';
    my $res = do_request('POST', $host.$url, $body, undef);
    ok $res->is_success, '1..' . $MODEL_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $MODEL_LIMIT) {
        is $res_body, '{"success":1}'."\n", "Model limit test ".$_;
    } else {
        is $res_body, '{"success":0,"error":"Exceeded model count limit '
            .$MODEL_LIMIT.'."}'."\n", "Model limit test ".$_;
    }
}

$res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

# column limit test
my @cols;
my $data = { description => 'blah', columns => \@cols };
for (1..$COLUMN_LIMIT - 1) {
    push @cols, { name => "Foo$_", label => 'abc' };
}

## 1. create a mode first (column number: $COLUMN_LIMIT - 1)
my $url = '/=/model/foos';
my $body = Dump($data);
$res = do_request('POST', $host.$url, $body, undef);
ok $res->is_success, 'Create model okay';
is $res->content(), '{"success":1}'."\n";

my @cols_bak = @cols;

## 2. step to exceed the column limit using add method
for ($COLUMN_LIMIT..$COLUMN_LIMIT + 1) {
    my $col_name = 'Foo'.$_;

    my $url_local = $url.'/'.$col_name;
    $body = '{label:"'.$col_name.'"}';

    $res = do_request('POST', $host.$url_local, $body, undef);
    ok $res->is_success, $COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $COLUMN_LIMIT) {
        is $res_body, '{"success":1,"src":"/=/model/foos/Foo'.$_.'"}'."\n", "Model column limit test - add column FOO".$_;
    } else {
        is $res_body, '{"success":0,"error":"Exceeded model column count limit: '.$COLUMN_LIMIT.'."}'."\n", "Model column limit test ".$_;
    }
}

## 3. post a mode which number of columns is $COLUMN_LIMIT
@cols = @cols_bak;
for ($COLUMN_LIMIT..$COLUMN_LIMIT + 2) {
    my $col_name = 'Foo'.$_;
    push @cols, { name => $col_name, label => $col_name };

    my $data = { description => 'blah', columns => \@cols };
    my $body = Dump($data);
    ### $body

    my $url = $host.$url;
    #die $url;
    $res = do_request('DELETE', $url, undef, undef);
    $res = do_request('POST', $url, $body, undef);
    ok $res->is_success, $COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $COLUMN_LIMIT) {
        is $res_body, '{"success":1}'."\n", "Model column limit test ".$_;
    } else {
        is $res_body, '{"success":0,"error":"Exceeded model column count limit: '.$COLUMN_LIMIT.'."}'."\n", "Model column limit test ". $_;
    }
}


# We need a faster way to test $RECORD_LIMIT because it's normally huge...

# insert limit test
## 1. delete the 'foo' model first
$res = do_request('DELETE', $host.$url, undef, undef);

## 2. create it
$body = '{description:"blah",columns:[{name:"title",label:"title"}]}';
$res = do_request('POST', $host.$url, $body, undef);
### $res_body

## 3. insert $RECORD_LIMIT - 1 records
for (1..$RECORD_LIMIT - 1) {
    $body = '{title:'.($RECORD_LIMIT-1).'}';
    ### $body
    $res = do_request('POST', $host.$url.'/~/~', $body, undef);
    ok $res->is_success, $COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
}

## 4. add 2 more records
for ($RECORD_LIMIT..$RECORD_LIMIT + 1) {
    $body = '{title:'.($RECORD_LIMIT-1).'}';

    ### $body
    $res = do_request('POST', $host.$url.'/~/~', $body, undef);
    ok $res->is_success, $RECORD_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $RECORD_LIMIT) {
        is $res_body, '{"success":1,"rows_affected":1,"last_row":"/=/model/foos/id/100"}'."\n", "Model record limit test ".$_;
    } else {
        is $res_body, '{"success":0,"error":"Exceeded model row count limit: '.$RECORD_LIMIT.'."}'."\n", "Model record limit test ".$_;
    }
}

$res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

=cut

