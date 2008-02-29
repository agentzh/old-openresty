package WWW::OpenResty;

use strict;
use warnings;

#use Smart::Comments;
use Carp;
use Params::Util qw( _HASH0 );
use LWP::UserAgent;
use Data::Dumper;

sub new {
    ### @_
    my $class = ref $_[0] ? ref shift : shift;
    my $params = _HASH0(shift @_) or croak "Invalid params";
    ### $params
    my $server = delete $params->{server} or
        croak "No server specified.";
    my $timer = delete $params->{timer};
    my $ua = LWP::UserAgent->new;
    $ua->cookie_jar({ file => "cookies.txt" });
    bless {
        server => $server,
        ua => $ua,
        timer => $timer,
    }, $class;
}

sub content_type {
    $_[0]->{content_type} = $_[1];
}

sub login {
    my ($self, $user, $password) = @_;
    my $res = $self->get("/=/login/$user/$password?use_cookie=1");
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
    my $ua = $self->{ua};
    $timer->start($method) if $timer;
    my $res = $ua->request($req);
    $timer->stop($method) if $timer;
    return $res;
}

1;

