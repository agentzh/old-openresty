package t::OpenResty;

#use Smart::Comments '####';
use lib 'lib';
use lib 'inc';
use Test::Base -Base;
use YAML::Syck ();
#use JSON::Syck ();
use JSON::XS ();
use Digest::MD5 qw(md5_hex);

my $client_module;
use OpenResty::Config;
BEGIN {
    OpenResty::Config->init('.');
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

our $server = $ENV{'OPENRESTY_TEST_SERVER'} ||
    $OpenResty::Config{'test_suite.server'} ||
    die "No test_suite.server specified.\n";
our ($user, $password, $host);
if ($server =~ /^(\w+):(\S+)\@(\S+)$/) {
    ($user, $password, $host) = ($1, $2, $3);
} else {
    die "test_suite.server syntax error in conf file: $server\n";
}
$password = md5_hex($password);

our $server2 = $ENV{'OPENRESTY_TEST_SERVER2'} ||
    $OpenResty::Config{'test_suite.server2'} ||
    die "No test_suite.server2 specified.\n";
our ($user2, $password2, $host2);
if ($server2 =~ /^(\w+):(\S+)\@(\S+)$/) {
    ($user2, $password2, $host2) = ($1, $2, $3);
} else {
    die "test_suite.server2 syntax error in conf file: $server2\n";
}
if ($host2 ne $host) { die "The two host names for test_suite.server and test_suite.server2 must be the same.\n"; }

$password2 = md5_hex($password2);

#### $user2
#### $password2

$host = "http://$host" if $host !~ m{^http://};

our $client = $client_module->new({ server => $host, timer => $timer });
our $debug = $OpenResty::Config{'frontend.debug'};

#init();

sub canon_json ($) {
    my $json = shift;
    #return undef unless defined $json;
    #### $json
    #local $JSON::Syck::SortKeys = 1;
    my $json_xs = JSON::XS->new->canonical->utf8->allow_nonref;
    if ($json =~ /^([^=]+)=(.*);$/) {
        my ($var, $true_json) = ($1, $2);
        my $data = $json_xs->decode($true_json);
        return "$var=" . $json_xs->encode($data) . ";\n";
    } elsif ($json =~ /^([^\(]+)\((.*)\);$/) {
        my ($func, $true_json) = ($1, $2);
        my $data = $json_xs->decode($true_json);
        return "$func(" . $json_xs->encode($data) . ");\n";
    }
    my $data = $json_xs->decode($json);
    return $json_xs->encode($data);
}

sub canon_yaml ($) {
    my $yaml = shift;
    return undef unless defined $yaml;
    my $data = YAML::Syck::Load($yaml);
    local $YAML::Syck::SortKeys = 1;
    return YAML::Syck::Dump($data);
}

sub smart_like ($$$$) {
    my ($got, $pattern, $desc, $format) = @_;
    $format ||= 'json';
    chomp($pattern);
    #warn "Pattern: $pattern";
    if (defined $got && $got !~ m/$pattern/) {
        if ($format eq 'json') {
            eval {
                $got = canon_json($got);
            };
        } elsif ($format eq 'yaml') {
            eval {
                $got = canon_yaml($got);
            };
        }
    }
    like $got, qr/$pattern/, $desc;
}

sub smart_is ($$$$) {
    my ($got, $expected, $desc, $format) = @_;
    $format ||= 'json';
    if (defined $got && defined $expected && $got ne $expected) {
        if ($format eq 'json') {
            #### old got: $got
            #### old expected: $expected
            eval {
                $got = canon_json($got);
            };
            if (!$@) {
                eval {
                    $expected = canon_json($expected);
                }
            };
            #### $got
            #### $expected
        } elsif ($format eq 'yaml') {
            eval {
                $got = canon_yaml($got);
                $expected = canon_yaml($expected);
            };
        } elsif ($format eq 'feed') {
            $got      =~ s{<((?:pub|lastBuild)Date)>.*?</\1>}{<$1>XXX</$1>}g;
            $expected =~ s{<((?:pub|lastBuild)Date)>.*?</\1>}{<$1>XXX</$1>}g;
        }
    }
    is $got, $expected, $desc;
}

sub run_tests () {
    for my $block (blocks()) {
        run_test($block);
    }
}

sub run_test ($) {
    my $block = shift;
    my $should_skip;
    if (!$debug && $block->debug) {
        return;
    }
    if ($debug && defined $block->debug && $block->debug == 0) {
        return;
    }
    #warn $block->use_ttf, "!@!!\n";
    if ($block->use_ttf && !-e 'font/wqy-zenhei.ttf') {
        $should_skip = 1;
    }
    if ($debug && $OpenResty::Config{'backend.type'} eq 'PgMocked' && $block->debug) { ok 1, 'skipped debug: 1' for 1..3; return; }
    my $name = $block->name;
    my $request = $block->request;
    if (!$request) {
        warn "No request section found in $name\n";
        return;
    }

    my $sleep_before=$block->sleep_before;
    if($sleep_before) {
        sleep $sleep_before;
    }

    my $charset = $block->charset || 'UTF-8';
    my $format = $block->format || 'JSON';
    my $res_type = $block->res_type;
    my $type = $block->request_type;
    if ($request) {
        $request =~ s/\$TestAccount\b/$user/g;
        $request =~ s/\$TestPass\b/$password/g;
        $request =~ s/\$TestAccount2\b/$user2/g;
        $request =~ s/\$TestPass2\b/$password2/g;
    }
    if ($request =~ /^(GET|POST|HEAD|PUT|DELETE)\s+([^\n]+)\s*\n(.*)/s) {
        my ($method, $url, $body) = ($1, $2, $3);
        $url =~ s/\$SavedCapture\b/$SavedCapture/g;
        $body =~ s/\$SavedCapture\b/$SavedCapture/g;
        if ($body =~ m/^"(?:\\"|[^"])*"$/) {
            $body =~ s/\n//g;
        }

        ### $method
        ### $url
        ### $body
        ### $host
        $url = $host.$url;
        from_to($url, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        from_to($body, 'UTF-8', $charset) unless $charset eq 'UTF-8';
        $client->content_type($type);
        my $res = $client->request($body, $method, $url);
        if ($should_skip) { return; }
        ok $res->is_success, "request returns OK - $name";
        if (!$res->is_success) { warn $res->status_line }
        #warn $res->content, '!!!!!!!!!!!!!!!';
        my $expected_res = $block->response || $block->response_like;
        if ($expected_res) {
            $expected_res =~ s/\$TestAccount\b/$user/g;
            $expected_res =~ s/\$TestPass\b/$password/g;
            $expected_res =~ s/\$TestAccount2\b/$user2/g;
            $expected_res =~ s/\$TestPass2\b/$password2/g;
        }
        if ($format eq 'JSON' and $expected_res) {
            $expected_res =~ s/\n[ \t]*([^\n\s])/$1/sg;
        }
        if ($expected_res) {
            if ($block->response_like) {
                if ($res->content =~ qr/$expected_res/) {
                    $SavedCapture = $1 if defined $1;
                }
                smart_like $res->content, $expected_res, "$name - response matched", lc($block->format);
            } else {
                from_to($expected_res, 'UTF-8', $charset) unless $charset eq 'UTF-8';
                smart_is $res->content(), $expected_res, "response content OK - $name", lc($block->format);
            }
        } else {
            smart_is $res->content(), $expected_res, "response content OK - $name", lc($block->format);
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

        my $sleep_after=$block->sleep_after;
        if($sleep_after) {
            sleep $sleep_after;
        }
    } else {
        my ($firstline) = ($request =~ /^([^\n]*)/s);
        die "Invalid request head: \"$firstline\" in $name\n";
    }
}

END {
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
            my $last_data = YAML::Syck::LoadFile($file);
            $cur_data = merge($cur_data, $last_data);
        }
        YAML::Syck::DumpFile($file, $cur_data);
    }
}

1;

