package WWW::OpenResty::Embedded;

use strict;
use warnings;

#use Smart::Comments;
use Carp;
use Params::Util qw( _HASH0 );
use OpenResty::Dispatcher;
use Data::Dumper;
use Class::Prototyped;
use HTTP::Request;
use HTTP::Response;
use CGI::Simple;
use CGI::Cookie;
use Test::Base;
use Encode qw(encode is_utf8);

our $Buffer;
our %Cookies;
my $Cgi = CGI::Simple->new;

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
    my $content = shift;
    $self->request($content, 'POST', @_);
}

sub put {
    my $self = shift;
    my $content = shift;
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
    $ENV{REQUEST_URI} = $uri;

    if (%Cookies) {
        my @vals;
        while (my ($key, $val) = each %Cookies) {
            push @vals, $val->as_string;
        }
        $ENV{COOKIE} = join('; ', @vals);
        ### My cookie: $ENV{COOKIE}
    }

    my $cgi = new_cgi($uri, $req);
    $Buffer = undef;
    OpenResty::Dispatcher->process_request($cgi);
    my $code;
    if (is_utf8($Buffer)) {
        $Buffer = encode('UTF-8', $Buffer);
    }
    if ($Buffer =~ /^HTTP\/1\.[01] (\d+) (\w+)\n/) {
        $code = $1;
    }
    my $res = HTTP::Response->parse($Buffer); # $code, $msg, $header, $content )
    ## $res
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

sub new_cgi {
    my ($uri, $req) = @_;
    $uri =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    my %url_params;
    if ($uri =~ /\?(.+)/) {
        my $list = $1;
        my @params = split /\&/, $list;
        for my $param (@params) {
            my ($var, $val) = split /=/, $param, 2;
            $url_params{$var} = $val;
        }
    }
    my $cgi = Class::Prototyped->new(
        param => sub {
            my ($self, $key) = @_;
            #warn "!!!!!$key!!!!";
            if ($key =~ /^(?:PUTDATA|POSTDATA)$/) {
                my $s = $req->content;
                if (!defined $s or $s eq '') {
                    return undef;
                }
                return $s;
            }
            $url_params{$key};
        },
        url_param => sub {
            my ($self, $name) = @_;
            #warn ">>>>>>>>>>>>>>> url_param: $name\n";
            if (defined $name) {
                return $url_params{$name};
            } else {
                return keys %url_params;
            }
        },
        header => sub {
            my $self = shift;
            return $Cgi->header(@_);
        },
    );
}

1;

