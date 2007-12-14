use t::OpenAPI 'no_plan';
#use Smart::Comments;
use constant {
    MODEL_LIMIT => 10,
    COLUMN_LIMIT => 10,
    RECORD_LIMIT => 100,
    INSERT_LIMIT => 20,
    POST_LEN_LIMIT => 10_000,
    PUT_LEN_LIMIT => 10_000,
};

my $host = $t::OpenAPI::host;
my $res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

for (1..MODEL_LIMIT + 1) {
    my $model_name = 'Foo'.int rand(19999);
    my $url = '/=/model/'.$model_name;
    ### $url
    my $body = '{description:"blah",columns:[{name:"title",label:"title"}]}';
    my $res = do_request('POST', $host.$url, $body, undef);
    ok $res->is_success, '1..' . MODEL_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= MODEL_LIMIT) {
        is $res_body, '{"success":1}'."\n", "Model limit test ".$_;
    } else {
        is $res_body, '{"sucess":0,"error":"Exceeded model count limit."}'."\n", "Model limit test ".$_;
    }
}

# column limit test
my $cols = '{name:"Foo1",label: "Foo1"}';
for (2..COLUMN_LIMIT - 1) {
    my $col_name = 'Foo'.$_;
	$cols .= ",{name:\"".$col_name."\",label: \"".$col_name."\"}";
}

## 1. create a mode first (column number: COLUMN_LIMIT - 1)
my $url = '/=/model/foos';
my $body = "{description:\"blah\",columns:[".$cols."]}";
$res = do_request('POST', $host.$url, $body, undef);

my $cols_bak = $cols;


## 2. step to exceed the column limit using add method
for (COLUMN_LIMIT..COLUMN_LIMIT + 1) {
    my $col_name = 'Foo'.$_;
    
    my $url_local = $url.'/'.$col_name;
    $body = '{label:"'.$col_name.'"}';

    $res = do_request('POST', $host.$url_local, $body, undef);
    ok $res->is_success, COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= COLUMN_LIMIT) {
        is $res_body, '{"success":1,"src":"/=/model/foos/Foo10"}'."\n", "Model column limit test - add column FOO".$_;
    } else {
        is $res_body, '{"sucess":0,"error":"Exceeded model count column limit."}'."\n", "Model column limit test ".$_;
    }
}

## 3. post a mode which number of columns is COLUMN_LIMIT 
$cols = $cols_bak;
for (COLUMN_LIMIT..COLUMN_LIMIT + 1) {
    my $url = '/=/model/foos';
    my $col_name = 'Foo'.$_;
    $cols .= ",{name:\"".$col_name."\",label:\"".$col_name."\"}";

    my $body = "{description:\"blah\",columns:[".$cols."]}";
    ### $body

    $res = do_request('DELETE', $host.$url, undef, undef);
    $res = do_request('POST', $host.$url, $body, undef);
    ok $res->is_success, COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= COLUMN_LIMIT) {
        is $res_body, '{"success":1}'."\n", "Model column limit test ".$_;
    } else {
        is $res_body, '{"sucess":0,"error":"Exceeded model count column limit."}'."\n", "Model column limit test ".$_;
    }
}

# insert limit test
#

$res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

