package t::OpenAPI;

use Test::Base -Base;

#use Smart::Comments;
use LWP::UserAgent;
use Test::LongString;

our @EXPORT = qw(init run_tests run_test);

my $ua = LWP::UserAgent->new;
my $host = $ENV{'REMOTE_OPENAPI'} || 'http://localhost';
$host = "http://$host" if $host !~ m{^http://};

sub init {
    my $res = do_request('DELETE', $host . '/=/model');
    ok $res->is_success, 'DELETE /=/model failed';
    is $res->content, '', 'no error msg';
}

#init();

sub do_request ($$$$) {
    my ($method, $url, $body, $type) = @_;
    $type ||= 'text/plain';
    my $req = HTTP::Request->new($method);
    $req->header('Content-Type' => $type);
    $req->header('Accept', '*/*');
    $req->url($url);
    if ($body) {
        if ($method eq 'GET' or $method eq 'HEAD') {
            die "HTTP 1.1 $method request should not have a content body: $body";
        }

        $req->content($body);
    } elsif ($method eq 'POST' or $method eq 'PUT') {
        $req->header('Content-Length' => 0);
    }
    return $ua->request($req);
}


sub run_tests () {
    for my $block (blocks()) {
        run_test($block);
    }
}

sub run_test ($) {
    my $block = shift;
    my $name = $block->name;
    my $request = $block->request;
    if (!$request) {
        warn "No request section found in $name\n";
        return;
    }
    my $type = $block->request_type;
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+(\S+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        ### $method
        ### $url
        ### $body
        ### $host
        my $res = do_request($method, $host.$url, $body, $type);
        ok $res->is_success, "request returns OK - $name";
        (my $expected_res = $block->response) =~ s/\n[ \t]*([^\n\s])/$1/sg;
        if ($expected_res) {
            is_string $res->content, $expected_res, "response content OK - $name";
        } else {
            is $res->content, $expected_res, "response content OK - $name";
        }
    } else {
        my ($firstline) = ($request =~ /^([^\n]*)/s);
        die "Invalid request head: \"$firstline\" in $name\n";
    }
}

1;

