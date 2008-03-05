package t::OpenResty;

use lib 'inc';
use lib 'lib';

use Test::Base -Base;

#use Smart::Comments;
my $client_module;
use OpenResty::Config;
BEGIN {
    OpenResty::Config->init;
    my $use_http = $OpenResty::Config{'test_suite.use_http'};
    if ($use_http) {
        $client_module = 'WWW::OpenResty';
        require WWW::OpenResty;
    } else {
        $client_module = 'WWW::OpenResty::Embedded';
        require WWW::OpenResty::Embedded;
    }
}
use Test::LongString;
use Encode 'from_to';

our @EXPORT = qw(init do_request run_tests run_test);

my $timer;
eval {
    require Benchmark::Timer;
    $timer = Benchmark::Timer->new();
};
my $SavedCapture;

our $server = $ENV{'OPENAPI_TEST_SERVER'} ||
    $OpenResty::Config{'test_suite.server'} or
    die "No server specified.\n";
our ($user, $password, $host);
if ($server =~ /^(\w+):(\S+)\@(\S+)$/) {
    ($user, $password, $host) = ($1, $2, $3);
} else {
    die "test_suite.server syntax error in conf file: $server\n";
}

$host = "http://$host" if $host !~ m{^http://};

our $client = $client_module->new({ server => $host, timer => $timer });
our $debug = $OpenResty::Config{'frontend.debug'};

#init();

sub run_tests () {
    for my $block (blocks()) {
        run_test($block);
    }
}

sub run_test ($) {
    my $block = shift;
    if (!$debug && $block->debug) {
        return;
    }
    if ($debug && defined $block->debug && $block->debug == 0) {
        return;
    }
    my $name = $block->name;
    my $request = $block->request;
    if (!$request) {
        warn "No request section found in $name\n";
        return;
    }
    my $charset = $block->charset || 'UTF-8';
    my $format = $block->format || 'JSON';
    my $res_type = $block->res_type;
    my $type = $block->request_type;
    if ($request) {
        $request =~ s/\$TestAccount\b/$user/g;
        $request =~ s/\$TestPass\b/$password/g;
    }
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+([^\n]+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        $url =~ s/\$SavedCapture\b/$SavedCapture/g;
        $body =~ s/\$SavedCapture\b/$SavedCapture/g;
        ### $method
        ### $url
        ### $body
        ### $host
        $url = $host.$url;
        from_to($url, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        from_to($body, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        $client->content_type($type);
        my $res = $client->request($body, $method, $url);
        ok $res->is_success, "request returns OK - $name";
        my $expected_res = $block->response || $block->response_like;
        if ($expected_res) {
            $expected_res =~ s/\$TestAccount\b/$user/g;
            $expected_res =~ s/\$TestPass\b/$password/g;
        }
        if ($format eq 'JSON' and $expected_res) {
            $expected_res =~ s/\n[ \t]*([^\n\s])/$1/sg;
        }
        if ($expected_res) {
            if ($block->response_like) {
                if ($res->content =~ qr/$expected_res/) {
                    $SavedCapture = $1 if defined $1;
                }
                like $res->content, qr/$expected_res/, "$name - response matched";
            } else {
                from_to($expected_res, 'UTF-8', $charset) unless $charset eq 'UTF-8';
                is $res->content, $expected_res, "response content OK - $name";
            }
        } else {
            is $res->content, $expected_res, "response content OK - $name";
        }
        if ($res_type) {
            my $true_res_type = $res->header('Content-Type');
            is $true_res_type, $res_type, "Content-Type in response ok - $name";
            if ($true_res_type ne $res_type and $true_res_type =~ m{text/plain}) {
                warn $res->content;
            }
        } else {
            like $res->header('Content-Type'), qr/\Q; charset=$charset\E$/, "charset okay - $name";
        }
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
    if ($timer) {
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
}

1;

