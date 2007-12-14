package t::OpenAPI;

use Test::Base -Base;

#use Smart::Comments;
use LWP::UserAgent;
use Test::LongString;
use Encode 'from_to';

our @EXPORT = qw(init do_request run_tests run_test);

use Benchmark::Timer;
my $timer = Benchmark::Timer->new();

my $ua = LWP::UserAgent->new;
our $host = $ENV{'REMOTE_OPENAPI'} || 'http://localhost';
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
    $timer->start($method);
    my $res = $ua->request($req);
    $timer->stop($method);
    return $res;
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
    my $charset = $block->charset || 'UTF-8';
    my $format = $block->format || 'JSON';
    my $type = $block->request_type;
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+(\S+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        ### $method
        ### $url
        ### $body
        ### $host
        $url = $host.$url;
        from_to($url, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        from_to($body, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        my $res = do_request($method, $url, $body, $type);
        ok $res->is_success, "request returns OK - $name";
        my $expected_res = $block->response;
        if ($format eq 'JSON') {
            $expected_res =~ s/\n[ \t]*([^\n\s])/$1/sg;
        }
        if ($expected_res) {
            from_to($expected_res, 'UTF-8', $charset) unless $charset eq 'UTF-8';
            is $res->content, $expected_res, "response content OK - $name";
        } else {
            is $res->content, $expected_res, "response content OK - $name";
        }
        like $res->header('Content-Type'), qr/\Q; charset=$charset\E$/, 'charset okay';
    } else {
        my ($firstline) = ($request =~ /^([^\n]*)/s);
        die "Invalid request head: \"$firstline\" in $name\n";
    }
}

END {
    use YAML::Syck;
    use Hash::Merge 'merge';
    #use Data::Dumper;
    #warn scalar $timer->reports;
    my $file = "t/cur-timer.dat";
    my $cur_data = $timer->data;
    if (!$cur_data) {
        return;
    }
    $cur_data = { @$cur_data };
    #warn Dumper($cur_data);
    if (-f $file) {
        my $last_data = LoadFile($file);
        $cur_data = merge($cur_data, $last_data);
    }
    DumpFile($file, $cur_data);
}

1;

