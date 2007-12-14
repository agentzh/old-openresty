use t::OpenAPI;
#use Smart::Comments;
use constant {
    MODEL_LIMIT => 10,
    COLUMN_LIMIT => 10,
    RECORD_LIMIT => 100,
    INSERT_LIMIT => 20,
    POST_LEN_LIMIT => 10_000,
    PUT_LEN_LIMIT => 10_000,
};
use Test::More 'no_plan';

my $host = $t::OpenAPI::host;
my $res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

for (1..MODEL_LIMIT+1) {
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
#
# insert limit test
#

$res = do_request('DELETE', $host.'/=/model', undef, undef);
ok $res->is_success, 'response OK';

