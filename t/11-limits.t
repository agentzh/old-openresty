#use Test::More 'no_plan';
#use Smart::Comments;
use lib 'lib';
use JSON::Syck 'Dump';
use OpenResty::Limits;

use OpenResty::Config;
my $reason;
BEGIN {
    OpenResty::Config->init;
    if ($OpenResty::Config{'backend.type'} eq 'PgMocked' ||
        $OpenResty::Config{'backend.recording'}) {
        $reason = 'Skipped in PgMocked or recording mode since too many tests here.';
    }
}
use t::OpenResty $reason ? (skip_all => $reason) : ('no_plan');
if ($reason) { return; }

my $host = $t::OpenResty::host;
my $client = $t::OpenResty::client;
my $res = $client->delete("/=/model?user=$t::OpenResty::user\&password=$t::OpenResty::password\&use_cookie=1");
ok $res->is_success, 'response OK';

for (1..$MODEL_LIMIT + 1) {
    my $model_name = 'Foo'.$_;
    my $url = '/=/model/'.$model_name;
    ### $url
    my $body = '{"description":"blah","columns":[{"name":"title","label":"title"}]}';
    my $res = $client->post($url, $body);
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

$res = $client->delete('/=/model');
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
$res = $client->post($url, $body);
ok $res->is_success, 'Create model okay';
is $res->content(), '{"success":1}'."\n";

my @cols_bak = @cols;

## 2. step to exceed the column limit using add method
for ($COLUMN_LIMIT..$COLUMN_LIMIT + 1) {
    my $col_name = 'Foo'.$_;

    my $url_local = $url.'/'.$col_name;
    $body = '{"label":"'.$col_name.'"}';

    $res = $client->post($url_local, $body);
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

    #my $url = $host.$url;
    #die $url;
    $res = $client->delete($url);
    $res = $client->post($url, $body);
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

# record limit test
## 1. delete the 'foo' model first
$res = $client->delete($url);

## 2. create it
$body = '{"description":"blah","columns":[{"name":"title","label":"title"}]}';
$res = $client->post($url, $body);
### $res

## 3. insert $RECORD_LIMIT - 1 records
for (1..$RECORD_LIMIT - 1) {
    $body = '{"title":'.($RECORD_LIMIT-1).'}';
    ### $body
    $res = $client->post($url.'/~/~', $body);
    ok $res->is_success, $COLUMN_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
}

## 4. add 2 more records
for ($RECORD_LIMIT..$RECORD_LIMIT + 1) {
    $body = '{"title":'.($RECORD_LIMIT-1).'}';

    ### $body
    $res = $client->post($url.'/~/~', $body);
    ok $res->is_success, $RECORD_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $RECORD_LIMIT) {
        is $res_body, '{"success":1,"rows_affected":1,"last_row":"/=/model/foos/id/'.$RECORD_LIMIT.'"}'."\n", "Model record limit test ".$_;
    } else {
        is $res_body, '{"success":0,"error":"Exceeded model row count limit: '.$RECORD_LIMIT.'."}'."\n", "Model record limit test ".$_;
    }
}

# insert limit test: the maximum records in a session
for ($INSERT_LIMIT..$INSERT_LIMIT + 1) {

    ## 1. delete the 'foo' model first, then create it
    $res = $client->delete($url);
    $body = '{"description":"blah","columns":[{"name":"title","label":"title"}]}';
    $res = $client->post($url, $body);
    ok $res->is_success, 'Create model okay';

    ## 2. insert some records in a session
	my @recs;
	for (1..$_) {
        push @recs, { title => "Foo$_" };
	}
    $body = Dump(\@recs);
    $res = $client->post($url.'/~/~', $body);
    ok $res->is_success, $INSERT_LIMIT . ' OK';
    my $res_body = $res->content;
    ### $res_body
    if ($_ <= $INSERT_LIMIT) {
        is $res_body, '{"success":1,"rows_affected":'.$_.',"last_row":"/=/model/foos/id/'.$_.'"}'."\n", "Model insert limit test - insert records number $_ once";
    } else {
        is $res_body, '{"success":0,"error":"You can only insert '.$INSERT_LIMIT.' rows at a time."}'."\n", "Model insert limit test ".$INSERT_LIMIT;
    }
}

# post length limit test
## new a data exceed the post length limit
$data = 'a' x ($POST_LEN_LIMIT + 1);
## delete the 'foo' model first, then create it
$res = $client->delete($url);
$body = '{"description":"blah",columns:[{"name":"title","label":"title"}]}';
$res = $client->post($url, $data);
ok $res->is_success, 'Create model okay';

$body = $data;
$res = $client->post($url.'/~/~', $body);
ok $res->is_success, $POST_LEN_LIMIT . ' OK';
my $res_body = $res->content;
### $res_body
is $res_body, '{"success":0,"error":"Exceeded POST content length limit: '.$POST_LEN_LIMIT.'"}'."\n", "Model post limit test ".$POST_LEN_LIMIT;

# put length limit test
## new a data exceed the post length limit
$data = 'a' x ($POST_LEN_LIMIT + 1);
## delete the 'foo' model first, then create it
$res = $client->delete($url);
$body = '{"description":"blah",columns:[{"name":"title","label":"title"}]}';
$res = $client->put($url, $body);
ok $res->is_success, $POST_LEN_LIMIT .'init model okay';

## insert a record
$body = '{ "title": "abc" }';
$res = $client->post($url.'/~/~', $body);
ok $res->is_success, $POST_LEN_LIMIT . 'insert a short record OK';
$res_body = $res->content;
### $res_body

$data = 'a' x ($POST_LEN_LIMIT + 1);
#$body = '{title:'.($data).'}';
$res = $client->put($url.'/id/1', $data);
ok $res->is_success, $POST_LEN_LIMIT . 'update OK';
$res_body = $res->content;
### $res_body
is $res_body, '{"success":0,"error":"Exceeded PUT content length limit: '.$POST_LEN_LIMIT.'"}'."\n", "Model put limit test ".$POST_LEN_LIMIT;

# max select records in a request
## delete the 'foo' model first, then create it
$res = $client->delete($url);
$body = '{"description":"blah","columns":[{"name":"title","label":"title"}]}';
$res = $client->post($url, $body);
ok $res->is_success, 'Create model okay';

## insert MAX_SELECT_LIMIT + 1 records
my @recs;
for (1..$MAX_SELECT_LIMIT + 1) {
    push @recs, { title => "Foo$_" };
}
$body = Dump(\@recs);
$res = $client->post($url.'/~/~', $body);
ok $res->is_success, $INSERT_LIMIT . ' OK';
$res_body = $res->content;
### $res_body

## request MAX_SELECT_LIMIT + 1 records
$res = $client->get($url.'/~/~?count='.($MAX_SELECT_LIMIT + 1));
ok $res->is_success, 'select OK';
$res_body = $res->content;
### $res_body
is $res_body, '{"success":0,"error":"Value too large for the limit param: '.($MAX_SELECT_LIMIT + 1).'"}'."\n", "Model select limit test ".$MAX_SELECT_LIMIT;

$res = $client->delete('/=/model');
ok $res->is_success, 'response OK';

