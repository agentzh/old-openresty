package WWW::OpenResty::Embedded;

use strict;
use warnings;

#use Smart::Comments;
use Carp;
use Params::Util qw( _HASH0 );
use OpenResty::Dispatcher;
use Data::Dumper;
use HTTP::Request;
use HTTP::Response;
use OpenResty::Util qw( new_mocked_cgi );
use CGI::Cookie;
use Test::Base;
use Encode qw(encode is_utf8);

our $Buffer;
our %Cookies;

*Test::Base::Handle::BINMODE = sub {};

sub new {
    ### @_
    my $class = ref $_[0] ? ref shift : shift;
    my $params = _HASH0(shift @_) or croak "Invalid params";
    ### $params
    my $server = delete $params->{server} or
        croak "No server specified.";
    my $timer = delete $params->{timer};
    OpenResty::Dispatcher->init;
    tie_output(*STDOUT, $Buffer);
    bless {
        server => $server,
        timer => $timer,
    }, $class;
}

sub content_type {
    $_[0]->{content_type} = $_[1];
}

sub login {
    my ($self, $user, $password) = @_;
    $self->get("/=/login/$user/$password");
}

sub get {
    my $self = shift;
    $self->request(undef, 'GET', @_);
}

sub post {
    my $self = shift;
    my $content = pop;
    $self->request($content, 'POST', @_);
}

sub put {
    my $self = shift;
    my $content = pop;
    $self->request($content, 'PUT', @_);
}

sub delete {
    my $self = shift;
    $self->request(undef, 'DELETE', @_);
}

sub request {
    my ($self, $content, $method, $url, $params) = @_;
    !defined $params or _HASH0($params) or
        die "Params must be a hash: ", Dumper($params), "\n";
    if ($params && %$params) {
        if ($url =~ /\?/) {
            die "? not allowed when params specified.\n";
        } else {
            my @params;
            while (my ($key, $val) = each %$params) {
                push @params, "$key=$val";
            }
            $url .= "?" . join '&', @params;
        }
    }
    my $type = $self->{content_type};
    $type ||= 'text/plain';
    if ($url !~ /^http:\/\//) {
        $url = $self->{server} . $url;
    }
    my $req = HTTP::Request->new($method);
    $req->header('Content-Type' => $type);
    $req->header('Accept', '*/*');
    $req->url($url);
    if ($content) {
        if ($method eq 'GET' or $method eq 'HEAD') {
            die "HTTP 1.0/1.1 $method request should not have content: $content\n";
        }

        $req->content($content);
    } elsif ($method eq 'POST' or $method eq 'PUT') {
        $req->header('Content-Length' => 0);
    }
    my $timer = $self->{timer};
    $timer->start($method) if $timer;
    my $res = _request($req);
    #my $res = $ua->request($req);
    $timer->stop($method) if $timer;
    return $res;
}

sub _request {
    my ($req) = @_;

    my $http_meth = $req->method;
    $ENV{REQUEST_METHOD} = $req->method;

    my $uri = $req->uri;
    #$uri =~ s/ /\%20/g;
    $uri =~ s/^http:\/\/[^\/]+//;
    if (is_utf8($uri)) {
        $uri = encode('utf8', $uri);
    }
    $ENV{REQUEST_URI} = $uri;
    (my $query = $uri) =~ s/(.*?\?)//g;
    #$query .= '&';
    $ENV{QUERY_STRING} = $query;

    if (%Cookies) {
        my @vals;
        while (my ($key, $val) = each %Cookies) {
            push @vals, $val->as_string;
        }
        $ENV{COOKIE} = join('; ', @vals);
        ### My cookie: $ENV{COOKIE}
    }

    my $cgi = new_mocked_cgi($uri, $req->content);
    $Buffer = undef;
    OpenResty::Dispatcher->process_request($cgi);
    my $code;
    #warn $Buffer;
    if (is_utf8($Buffer)) {
        $Buffer = encode('utf8', $Buffer);
    }
    if ($Buffer =~ /^HTTP\/1\.[01] (\d+) (\w+)\n/) {
        $code = $1;
    }
    my $res = HTTP::Response->parse($Buffer); # $code, $msg, $header, $content )
    ## $res
    #warn "---------- res: ", $res->is_success;
    my $raw_cookie = $res->header('Set-Cookie');
    #warn "RAW Cookie: $raw_cookie\n";
    if ($raw_cookie) {
        %Cookies = (%Cookies, CGI::Cookie->parse($raw_cookie));
    }
    ### %Cookies

    ## $raw_cookie
    ## $Buffer
    $res;
}

1;

