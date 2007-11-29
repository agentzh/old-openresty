use Test::Base;
use LWP::UserAgent;
#use Smart::Comments;

plan tests => 2 * blocks();

my $ua = LWP::UserAgent->new;
my $host = 'http://localhost';

sub init {
    my $res = do_request('DELETE', $host . '/=/model');
    ok $res->is_success, 'DELETE /=/model failed';
    is $res->content, '', 'no error msg';
}

#init();

sub do_request {
    my ($method, $url, $body, $type) = @_;
    $type ||= 'text/plain';
    my $req = HTTP::Request->new($method);
    $req->header('Content-Type' => $type);
    $req->header('Accept', '*/*');
    $req->url($url);
    if ($body) {
        $req->content($body);
    }
    return $ua->request($req);
}

run {
    my $block = shift;
    my $name = $block->name;
    my $request = $block->request;
    my $type = $block->request_type;
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+(\S+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        ### $method
        ### $url
        ### $body
        my $res = do_request($method, $host.$url, $body, $type);
        ok $res->is_success, "request returns OK - $name";
        is $res->content, $block->response, "response content OK - $name";
    } else {
        my ($firstline) = ($request =~ /^([^\n]*)/s);
        die "Invalid request head: \"$firstline\" in $name\n";
    }

};

__DATA__

=== TEST 1: Delete existing modes
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 3: Create a model
--- request
POST /=/model.js
{
    name: 'Bookmark',
    description: '我的书签',
    columns: [
        { name: 'id', type: 'serial', label: 'ID' },
        { name: 'title', label: '标题' },
        { name: 'url', label: '网址' }
    ]
}
--- response
{"success":1}



==== TEST 4: check the model list again
--- request
GET /=/model.js
--- response
[{"src":"/=/model/Bookmark","name":"Bookmark","description":"我的书签"}]

