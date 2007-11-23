use Test::Base;
use LWP::UserAgent;
#use Smart::Comments;

plan tests => 3 * blocks();

my $ua = LWP::UserAgent->new;
my $host = 'http://localhost';

run {
    my $block = shift;
    my $name = $block->name;
    my $request = $block->request;
    my $type = 'text/plain';
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+(\S+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        ### $method
        ### $url
        ### $body
        my $req = HTTP::Request->new($method);
        $req->header('Content-Type' => $type);
        $req->header('Accept', '*/*');
        $req->url($host . $url);
        if ($body) {
            $req->content($body);
        }
        my $res = $ua->request($req);
        ok $res->is_success, "request returns OK - $name";
        is $res->content, $block->response, "response content OK - $name";
    } else {
        my ($firstline) = ($request =~ /^([^\n]*)/s);
        die "Invalid request head: \"$firstline\" in $name\n";
    }

};

__DATA__

=== TEST 1: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 2: Create a model
--- request
POST /=/model.js
{
    name: 'Bookmark',
    description: '我的书签',
    columns: [
        { name: 'id', type: 'serial', label: 'ID' },
        { name: 'title', label: '标题' },
        { name: 'url', label: '网址' },
    ]
}
--- response
{success:'true'}

