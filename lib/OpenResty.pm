package OpenResty;

our $VERSION = '0.005009';

use strict;
use warnings;

#use Smart::Comments '####';
use Data::UUID;
use YAML::Syck ();
use JSON::XS ();
use Compress::Zlib;

use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY0 _ARRAY _SCALAR);
use Encode qw(from_to encode decode);
use Data::Structure::Util qw( _utf8_on _utf8_off );
use DBI;
use OpenResty::QuasiQuote::SQL;

use OpenResty::SQL::Select;
use OpenResty::SQL::Update;
use OpenResty::SQL::Insert;

use OpenResty::Backend;
use OpenResty::Limits;

#use encoding "utf8";

use OpenResty::Util;
use Encode::Guess;

#$YAML::Syck::ImplicitUnicode = 1;
#$YAML::Syck::ImplicitBinary = 1;

our ($Backend, $BackendName);
our (%AccountFiltered, %UnsafeAccounts, %UnlimitedAccounts );
our $Cache;
our $UUID = Data::UUID->new;

# XXX we should really put this into the Action handler...
our %AllowForwarding;

our $JsonXs = JSON::XS->new->utf8->allow_nonref;

our %OpMap = (
    contains => 'like',
    gt => '>',
    ge => '>=',
    lt => '<',
    le => '<=',
    eq => '=',
    ne => '<>',
);

sub json_encode {
    _utf8_on($_[0]);
    local *_ = \( $JsonXs->encode($_[0]) );
    _utf8_off($_[0]);
    $_;
}

our %ext2dumper = (
    '.yml' => sub { _utf8_on($_[0]); YAML::Syck::Dump($_[0]); },
    '.yaml' => sub { _utf8_on($_[0]); YAML::Syck::Dump($_[0]); },
    '.js' => \&json_encode,
    '.json' => \&json_encode,
);

our %EncodingMap = (
    'cp936' => 'GBK',
    'utf8'  => 'UTF-8',
    'euc-cn' => 'GB2312',
    'big5-eten' => 'Big5',
);

our %ext2importer = (
    '.yml' => \&YAML::Syck::Load,
    '.yaml' => \&YAML::Syck::Load,
    '.js' => sub { $JsonXs->decode($_[0]) },
    '.json' => sub { $JsonXs->decode($_[0]) },
);

our $Ext = qr/\.(?:js|json|xml|yaml|yml)/;
#our $Dumper = 
our $Dumper = $ext2dumper{'.js'};
our $Importer = $ext2importer{'.js'};

sub version {
    (my $ver = $OpenResty::VERSION) =~ s{^(\d+)\.(\d{3})(\d{3})$}{join '.', int($1), int($2), int($3)}e;
    $ver;
}

# XXX more data types...
sub parse_data {
    #shift;
    my $data = $_[0]->{_importer}->($_[1]);
    _utf8_off($data);
    return $data;
}

sub new {
    my ($class, $cgi, $call_level) = @_;
    return bless {
        _cgi => $cgi,
        _client_ip => $cgi->remote_host(),
        _charset => 'UTF-8',
        _call_level => $call_level,
        _dumper => $Dumper,
        _importer => $Importer,
        _http_status => 'HTTP/1.1 200 OK',
        _unlimited => undef
    }, $class;
}

sub call_level {
    return $_[0]->{_call_level};
}

sub config {
    my $key = pop;
    $OpenResty::Config{$key};
}

sub cache {
    $OpenResty::Cache;
}

sub init {
    my ($self, $rurl) = @_;
    my $class = ref $self;
    my $cgi = $self->{_cgi};

    if (!$Backend || !$Backend->ping) {
        warn "Re-connecting the database...\n";
        eval { $Backend->disconnect };
        OpenResty::Dispatcher->init({});
    }

    # cache the results of CGI::Simple::url_param
    my (%url_params, %builtin_params);

    my $cgi2 = bless {}, 'CGI::Simple';
    $cgi2->_parse_params( $ENV{'QUERY_STRING'} );
    for my $param ($cgi2->param) {
        if ($param =~ /^[A-Za-z]\w*$/) {
            $url_params{$param} = $cgi2->param($param);
        } elsif ($param =~ /^_\w+/) {
            $builtin_params{$param} = $cgi2->param($param);
        }
    }

    $self->{_url_params} = \%url_params;
    $self->{_builtin_params} = \%builtin_params;
    $self->{_use_cookie}  = $self->builtin_param('_use_cookie') || 0;
    $self->{_session}  = $self->builtin_param('_session');

    my $charset = $self->builtin_param('_charset') || 'UTF-8';

    if ($charset =~ /^guess(?:ing)?$/i) {
        undef $charset;
        my $url  = $ENV{REQUEST_URI};
        $url =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        ### Raw URL: $url
        my $data = $url .
            ($cgi->param('PUTDATA') || '') .
            ($cgi->param('POSTDATA') || '');
        ### $data
        my @enc = qw( UTF-8 GB2312 Big5 GBK Latin1 );
        for my $enc (@enc) {
            my $decoder = guess_encoding($data, $enc);
            if (ref $decoder) {
                $charset = $decoder->name;
                $charset = $EncodingMap{$charset} || $charset;
                last;
            }
        }
        if (!$charset) {
            die "Can't determine the charset of the input.\n";
        }
        ### $charset
    }
    $self->{'_charset'} = $charset;

    $self->{'_var'} = $self->builtin_param('_var');
    $self->{'_callback'} = $self->builtin_param('_callback');

    my $offset = $self->builtin_param('_offset');
    $offset ||= 0;
    if ($offset !~ /^\d+$/) {
        die "Invalid value for the \"offset\" param: $offset\n";
    }
    $self->{_offset} = $offset;

    my $limit = $self->builtin_param('_count');
    # limit is an alias for count
    if (!defined $limit) {
        $limit = $self->builtin_param('_limit');
    }
    if (!defined $limit) {
        $limit = $MAX_SELECT_LIMIT;
    } else {
        $limit ||= 0;
        if ($limit !~ /^\d+$/) {
            die "Invalid value for the \"_count\" param: $limit\n";
        }
        if ($limit > $MAX_SELECT_LIMIT) {
            die "Value too large for the _limit param: $limit\n";
        }
    }
    $self->{_limit} = $limit;

    my $http_meth = $ENV{REQUEST_METHOD};

    my $url = $$rurl;
    if ($charset ne 'UTF-8') {
        eval {
            #warn "HERE!";
            from_to($url, $charset, 'utf8');
        };
        warn $@ if $@;
    }
    #warn $url;

    $url =~ s{/+$}{}g;
    $url =~ s/\%2A/*/g;
    if ($url =~ s/$Ext$//) {
        my $ext = $&;
        # XXX obsolete
        $self->set_formatter($ext);
    } else {
        $self->set_formatter;
    }
    my $req_data;
    if ($http_meth eq 'POST') {
        $req_data = $cgi->param('POSTDATA');
        #die "Howdy! >>$req_data<<", $cgi->param('data'), "\n";
        #die $Dumper->(\%ENV);

        if (!defined $req_data) {
            $req_data = $cgi->param('data');
            if (!defined $req_data) {
                my $len = $ENV{CONTENT_LENGTH} || 0;
                if ($len > $POST_LEN_LIMIT) {
                    die "Exceeded POST content length limit: $POST_LEN_LIMIT\n";
                } else {
                    die "No POST content specified or no \"data\" field found.\n";
                }
            }
        } else {
            if (length($req_data) > $POST_LEN_LIMIT) {
                die "Exceeded POST content length limit: $POST_LEN_LIMIT\n";
            }
        }
    }
    elsif ($http_meth eq 'PUT') {
        $req_data = $cgi->param('PUTDATA');

        if (!defined $req_data) {
            $req_data = $cgi->param('data');
            if (!defined $req_data) {
                my $len = $ENV{CONTENT_LENGTH} || 0;
                if ($len > $POST_LEN_LIMIT) {
                    die "Exceeded PUT content length limit: $POST_LEN_LIMIT\n";
                } else {
                    die "No PUT content specified.\n";
                }
            }
        } else {
            if (length($req_data) > $POST_LEN_LIMIT) {
                die "Exceeded PUT content length limit: $POST_LEN_LIMIT\n";
            }
        }
    }

    if ($http_meth eq 'POST' and $url =~ s{^=/put/}{=/}) {
        $http_meth = 'PUT';
    } elsif ($http_meth =~ /^(?:GET|POST)$/ and $url =~ s{^=/delete/}{=/}) {
        $http_meth = 'DELETE';
    } elsif ($http_meth eq 'GET' and $url =~ s{^=/(post|put)/}{=/} ) {
        $http_meth = uc($1);
        $req_data = $self->builtin_param('_data');
        #$req_data = $Importer->($content);

        #warn "Content: ", $Dumper->($content);
        #warn "Data: ", $Dumper->($req_data);
    }

    #
    $$rurl = $url;
    $self->{'_url'} = $url;
    $self->{'_http_method'} = $http_meth;

    if ($req_data) {
        from_to($req_data, $charset, 'UTF-8');
        #warn "from_to is_utf8(req_data): ", Encode::is_utf8($req_data), "\n";
        $req_data = $self->parse_data($req_data);
    }

    $self->{_req_data} = $req_data;
}

sub fatal {
    my ($self, $s) = @_;
    #warn "fatal-ing...: $s\n";
    $self->error($s);
    $self->response();
}

sub error {
    my ($self, $s) = @_;
    my $lowlevel = ($s =~ s/^DBD::Pg::(?:db|st) \w+ failed:\s*//);
    #warn $s, "\n";
    if ($s =~ s{^\s*ERROR:\s+PL/Proxy function \w+.\w+\(\d+\): remote error:\s*}{}) {
        $s =~ s/\s+CONTEXT:  .*//s;
    }
    $s =~ s/^ERROR:\s*//g;
    if (!$OpenResty::Config{'frontend.debug'} && $lowlevel) {
        $s = 'Operation failed.';
    } else {
        $s =~ s/(.+) at \S+\/OpenResty\.pm line \d+(?:, <DATA> line \d+)?\.?$/Syntax error found in the JSON input: $1./;
        $s =~ s{ at \S+ line \d+\.?$}{}g;
        $s =~ s{ at \S+ line \d+, <\w+> line \d+\.?$}{}g;
    }
    #$s =~ s/^DBD::Pg::db do failed:\s.*?ERROR:\s+//;
    $self->{_error} .= $s . "\n";

}

sub data {
    $_[0]->{_data} = $_[1];
}

sub warning {
    $_[0]->{_warning} = $_[1];
}

sub http_status {
    $_[0]->{_http_status} = $_[1];
}

sub response {
    my $self = shift;
    if ($self->{_no_response}) { return; }
    my $charset = $self->{_charset};
    my $cgi = $self->{_cgi};
    my $cookie_data = $self->{_cookie};
    my @cookies;
    if ($cookie_data) {
        while (my ($key, $val) = each %$cookie_data) {
            push @cookies, CGI::Simple::Cookie->new(
                -name => $key, -value => $val
            );
        }
    }

    my $use_gzip = $OpenResty::Config{'frontend.use_gzip'} &&
        index($ENV{HTTP_ACCEPT_ENCODING} || '', 'gzip') >= 0;
    #warn "use gzip: $use_gzip\n";
    my $http_status = $self->{_http_status};
    if ($OpenResty::Server::IsRunning) {
        print "$http_status\r\n";
    } else {
        $http_status =~ s{^\s*HTTP/\d+\.\d+\s*}{};
        #warn "http_status: $http_status\n";
        binmode \*STDOUT;
        print "Status: $http_status\r\n";
    }
    #print "$http_status\r\n";
    # warn "$http_status";
    my $type = $self->{_type} || 'text/plain';
    #warn $s;
    my $str = '';
    if (my $bin_data = $self->{_bin_data}) {
        local $_;
        if (my $callback = $self->{_callback}) {
            chomp($bin_data);
            *_ = \"$callback($bin_data);\n";
        } else {
            *_ = \$bin_data;
        }

        print $cgi->header(
            -type => "$type" . ($type =~ /text/ ? "; charset=$charset" : ""),
            '-content-length' => length,
            @cookies ? (-cookie => \@cookies) : ()
        ), $_;
        return;
    }
    if (exists $self->{_error}) {
        $str = $self->emit_error($self->{_error});
    } elsif (exists $self->{_data}) {
        my $data = $self->{_data};
        if ($self->{_warning}) {
            $data->{warning} = $self->{_warning};
        }
        $str = $self->emit_data($data);
    }
    #die $charset;
    # XXX if $charset is 'UTF-8' then don't bother decoding and encoding...
    if ($charset ne 'UTF-8') {
        #warn "HERE!";
        eval {
            #$str = decode_utf8($str);
            #if (is_utf8($str)) {
                #} else {
                #warn "Encoding: $charset\n";
            from_to($str, 'utf8', $charset);
                #$str = decode('UTF-8', $str);
                #$str = encode($charset, $str);
                #}
        }; warn $@ if $@;
    }
    #warn $Dumper;
    #warn $ext2dumper{'.js'};
    $str =~ s/\n+$//s;
    if (my $var = $self->{_var}) {
        if ($self->{_dumper} eq $ext2dumper{'.js'}) {
            $str = "$var=$str;";
        } else {
            $str = "$var=" . OpenResty::json_encode($str) . ";";
        }
    } elsif (my $callback = $self->{_callback}) {
        if ($self->{_dumper} eq $ext2dumper{'.js'}) {
            $str = "$callback($str);";
        } else {
            $str = "$callback(" . OpenResty::json_encode($str) . ");";
        }
    }

    #my $meth = $self->{_http_method};
    if (my $LastRes = $OpenResty::Dispatcher::Handlers{last}) {
        $LastRes->set_last_response($self, $str);
    }
    #warn ">>>>>>>>>>>>Cookies<<<<<<<<<<<<<<: @cookies\n";
    #if (length($str) < 500 && $use_gzip) {
    #undef $use_gzip;
    #}
    {
        local $_;
        if ($use_gzip) {
            # compress the content part
            *_ = \(Compress::Zlib::memGzip($str));
        } else {
            *_ = \"$str\n";
        }

        print $cgi->header(
            -type => "$type" . ($type =~ /text/ ? "; charset=$charset" : ""),
            '-content-length' => length,
            $use_gzip ? ('-content-encoding' => 'gzip', '-accept-encoding' => 'Vary') : (),
            @cookies ? (-cookie => \@cookies) : ()
        ), $_;
    }
}

sub set_formatter {
    my ($self, $ext) = @_;
    $ext ||= '.js';
    #warn "Ext: $ext";
    $self->{_dumper} = $ext2dumper{$ext};
    $self->{_importer} = $ext2importer{$ext};
}

sub connect {
    my $self = shift;
    my $name = shift || $BackendName;
    $BackendName = $name;
    #warn "connect: $BackendName\n";
    $Backend = OpenResty::Backend->new($name);
    #warn "Backend: $Backend\n";
    #$Backend->select("");
}

sub emit_data {
    my ($self, $data) = @_;
    #warn "$data";
    return $self->{_dumper}->($data);
}

sub get_session {
    my ($self) = @_;
    my $session_from_cookie;
    my $call_level = $self->{_call_level};
    if ($call_level == 0) { # only check cookies on the toplevel call
        my $cookies = CGI::Cookie::XS->fetch;
        if ($cookies) {
            my $cookie = $cookies->{session};
            if ($cookie) {
                $self->{_session_from_cookie} =
                    $session_from_cookie = $cookie->[-1];
            }
        }
    }
    $self->{_session} || $session_from_cookie;
}

sub has_feed {
    my ($self, $feed) = @_;

    _IDENT($feed) or die "Bad feed name: $feed\n";
    my $sql = [:sql|
        select id
        from _feeds
        where name = $feed
        limit 1;
    |];
    my $ret;
    eval { $ret = $self->select($sql)->[0][0]; };
    return $ret;
}

sub has_role {
    my ($self, $role) = @_;
    return 'password' if $role eq 'Admin';
    return 'anonymous' if $role eq 'Public'; # shortcut...
    _IDENT($role) or
        die "Bad role name: ", $self->dump($role), "\n";


    my $user = $self->current_user;
    if (my $login_meth = $Cache->get_has_role($user, $role)) {
        #warn "has view cache HIT\n";
        #warn "from cache: $login_meth\n";
        return $login_meth;
    }

    my $sql = [:sql|
        select login
        from _roles
        where name = $role
        limit 1;
    |];
    my $ret = $self->select($sql);
    if ($ret && ref $ret) {
        $ret = $ret->[0][0];
        #warn "Returned: $ret\n";
        if ($ret) { $Cache->set_has_role($user, $role, $ret) }
        return $ret;
    }
    return undef;
    #warn "HERE!";
}

sub has_view {
    my ($self, $view) = @_;
    my $user = $self->current_user;

    _IDENT($view) or die "Bad view name: $view\n";

    if ($Cache->get_has_view($user, $view)) {
        #warn "has view cache HIT\n";
        return 1;
    }
    #warn "HERE!!! has_view: $view";
    my $sql = [:sql|
        select id
        from _views
        where name = $view
        limit 1;
    |];
    my $ret;
    eval { $ret = $self->select($sql)->[0][0]; };
    if ($ret) { $Cache->set_has_view($user, $view) }
    return $ret;
}

sub has_model {
    my ($self, $model) = @_;
    my $user = $self->current_user;

    _IDENT($model) or die "Bad model name: $model\n";
    if ($Cache->get_has_model($user, $model)) {
        #warn "has model cache HIT\n";
        return 1;
    }
    my $sql = [:sql|
        select c.oid
        from pg_catalog.pg_class c left join pg_catalog.pg_namespace n on n.oid = c.relnamespace
        where c.relkind in ('r','') and
              n.nspname = $user and
              pg_catalog.pg_table_is_visible(c.oid) and
              substr(c.relname,1,1) <> '_' and
              c.relname = $model
              limit 1
    |];

    my $ret;
    eval { $ret = $self->select($sql)->[0][0]; };
    if ($ret) { $Cache->set_has_model($user, $model) }
    return $ret;
}

sub has_user {
    my ($self, $user) = @_;
    if ($user && $Cache->get_has_user($user)) {
        #warn "Cache hit for has_user!";
        return 1;
    } else {
        my $res = $Backend->has_user($user);
        if ($res) {
            $Cache->set_has_user($user);
        }
        return $res;
    }
}

sub set_user {
    my ($self, $user) = @_;
    $Backend->set_user($user);
    $self->{_user} = $user;
}

sub current_user {
    my ($self) = @_;
    # warn "!!!", $self->{_user};
    $self->{_user};
}

sub do {
    my $self = shift;
    $Backend->do(@_);
}

sub select {
    my $self = shift;
    $Backend->select(@_);
}

sub last_insert_id {
    my $self = shift;
    $Backend->last_insert_id(@_);
}

sub emit_error {
    my $self = shift;
    my $msg = shift;
    $msg =~ s/\n+$//s;
    return $self->emit_data( { success => 0, error => $msg } );
}

sub set_role {
    my ($self, $role) = @_;
    $self->{_role} = $role;
}

sub get_role {
    $_[0]->{_role}
}

sub set_unlimited {
    $_[0]->{_unlimted} = shift;
}

sub is_unlimited {
    return $_[0]->{_unlimited};
}

sub url_param {
    if (@_ > 1) {
        $_[0]->{_url_params}->{$_[1]};
    } else {
        keys %{ $_[0]->{_url_params} };
    }
}

sub builtin_param {
    if (@_ > 1) {
        $_[0]->{_builtin_params}->{$_[1]};
    } else {
        keys %{ $_[0]->{_builtin_params} };
    }
}

1;
__END__

=encoding UTF-8

=head1 NAME

OpenResty - General-purpose web service platform for web applications

=head1 VERSION

This document describes OpenResty 0.5.9 released on May 6, 2009.

=head1 DESCRIPTION

This module implements the server-side OpenResty web service protocol. It provides scriptable and extensible web services for both server-side and client-side (pure AJAX) web applications.

Currently this module can serve as a public web interface to a distributed or desktop PostgreSQL database system. In particular, it provides roles, models, views, actions, captchas, the minisql language, and many more to the web users.

"Another framework?" No, no, no, not all!

OpenResty is I<not> a web application framework like L<Jifty> or L<Catalyst>. Rather, it is

=over

=item *

A REST wrapper for relational databases

=item *

A web runtime for 100% JavaScript web sites and other RIAs.

=item *

A "meta web site" supporting other sites via web services.

=item *

A handy personal or company database which can be accessed from anywhere
on the web.

=item *

A (sort of) competitor for the Facebook Data Store API.

=back

We're already running an instance of the OpenResty server on our Yahoo! China's production machines:

L<http://api.openresty.org/=/version>

And there're several (pure-client-side) web sites alreadying taking advantage of the services:

=over

=item OpenResty's admin site

L<http://openresty.org/admin/>

=item agentzh's blog and EEEE Works' blog

L<http://blog.agentzh.org>

L<http://eeeeworks.org>

=item Yisou BBS

L<http://www.yisou.com/opi/post.html>

=back

See L<OpenResty::Spec::Overview> for more detailed information.

L<OpenResty::CheatSheet> also provides a good enough summary for the REST interface.

You'll find my slides for the D2 conference interesting as well:

L<http://agentzh.org/misc/openresty-d2.pdf>

or the original XUL version:

L<http://agentzh.org/misc/openresty-d2/openresty-d2.xul> (Firefox required)

Another good introduction to OpenResty's REST API is summerized in the slides for my Y!ES talk and my Beijing Perl Workshop 2008 talk:

L<http://agentzh.org/misc/openresty-yes.pdf>

and a more pretty (XUL) version can be got from here:

L<http://agentzh.org/misc/openresty-yes/openresty-yes.xul> (Firefox required)

There're also a few interesting discussions about OpenResty on my blog site:

=over

=item "OpenResty versus Google App Engine"

L<http://blog.agentzh.org/#post-75>

=item "Google's crawlers captured OpenResty's API!"

L<http://blog.agentzh.org/#post-79>

=item "Video for my D2 talk about OpenResty and its nifty apps"

L<http://blog.agentzh.org/#post-81>

=item "The first yahoo.cn feature that is powered by OpenResty"

L<http://blog.agentzh.org/#post-86>

=item "Client-side web site DIY" (Chinese)

L<http://blog.agentzh.org/#post-80>

=item "OpenResty 平台相关资料" (Chinese)

L<http://www.eeeeworks.org/#post-6>

=back

=head1 CAVEATS

This library is still in the B<beta> phase and the API is still in flux. We're just following the "release early, releaes often" guideline. So please check back often ;)

=head1 INSTALLATION

Please see L<OpenResty::Spec::Install> for details :)

=head1 SOURCE TREE STRUCTURE

=over

=item bin/

contains some command-line utilities, among which the L<openresty> is the most important one.

=item lib/

contains all the server code, mostly Perl.

=item haskell/

contains the RestyScript compiler for OpenResty
written in Haskell. Support for both OpenResty Views and Actions
is provided.

See F<haskell/README> for more details.

=item font/

contains the font file (*.ttf) for captcha generation.

=item etc/

contains the config files, F<openresty.conf> and F<site_openresty.conf>. The latter one takes precedence over the former.

=item grammar/

contains L<Parse::Yapp> grammar files for the old OpenResty View (or minisql) compiler.

=item t/

contains the test suite.

=item demo/

contains a bunch of OpenResty demo apps.

=item inc/

generated by L<Module::Install> for CPAN building system.

=back

=head1 PERFORMANCE

OpenResty takes runtime performance very seriously because we have to run it on our not-so-good servers and support lots of Yahoo! China's online products with very heavy traffic.

OpenResty prefers modules with XS over pure Perl ones and uses cache aggressively. It's also in favor of source-filter based solutions provided by L<Filter::QuasiQuote> to reduce the length of subroutine calling chains and the number of indirections. Finally, the restyscript compiler is also written in carefully optimized Haskell code to maximize speed.

The benchmark results for OpenResty 0.5.3's test suite on a PentiumIV 3.0GHz machine is given below:

=over

=item in-process frontend + PgMocked backend

    DELETE: 4 ms (157 trials)
    POST: 23 ms (493 trials)
    PUT: 5 ms (132 trials)
    GET: 4 ms (648 trials)

=item lighttpd fastcgi frontend + local Pg backend

    DELETE: 29 ms (193 trials)
    POST: 30 ms (815 trials)
    PUT: 11 ms (138 trials)
    GET: 9 ms (763 trials)

=item lighttpd fastcgi frontend + remote PgFarm backend

    DELETE: 99 ms (193 trials)
    POST: 98 ms (815 trials)
    PUT: 41 ms (138 trials)
    GET: 24 ms (763 trials)

=back

=head1 SOURCE CONTROL

For the very latest version of this module, check out the source from
the Git repos below:

L<http://github.com/agentzh/openresty/tree/master>

There is anonymous access to all. If you'd like a commit bit, please let
us know. :)

=head1 Mailing list

Subscribe to the C<openresty> Google Group here:

  L<http://groups.google.com/group/openresty>

=head1 Project Roadmap

Below is a list of currently planned release milestones (but it's also supposed to change as we go):

=over

=item 0.5.x (Where we are)

Action API and an enhanced version of the Model API.

=item 0.6.x

Migrate the View handler to the same style and implementation of the Action handler, i.e., using explicit parameter list and taking advantage of the Haskell version of the restyscript compiler.

Compiling view definition to native PostgreSQL functions is also supposed to realize in this series.

=item 0.7.x

Attachment API, which supports binary file uploading and downloading.

=item 0.8.x

Mail API, which introduces builtin Models for email sentbox and inbox based on third-party POP3/STMP servers.

It will also allow actions to be triggered and/or confirmed by emails.

=item 0.9.x

Prophet/Git integration.

=back

Please don't hesitate to tell us what you love to see in future releases of OpenResty ;)

=head1 TODO

For the project's TODO list, please check out L<http://svn.openfoundry.org/openapi/trunk/TODO>

=head1 BUGS

There must be some serious bugs lurking somewhere given the current status of the implementation and test suite.

Please report bugs or send wish-list to
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=OpenResty>.

=head1 AUTHORS

=over

=item Agent Zhang (agentzh) C<< <agentzh at yahoo dot cn> >>

=item Xunxin Wan (万珣新) C<< <wanxunxin at gmail dot com > >>

=item chaoslawful (王晓哲) C<< <chaoslawful at gmail dot com> >>

=item Lei Yonghua (leiyh)

=item Laser Henry (laser) C<< <laserhenry at gmail dot com> >>

=item Yu Ting (yuting) C<< <yuting at yahoo dot cn> >>

=back

For a complete list of the contributors, please see L<http://svn.openfoundry.org/openapi/trunk/AUTHORS>.

=head1 License and Copyright

OpenResty is licensed under the BSD License:

Copyright (c) 2007-2008, Yahoo! China EEEE Works, Alibaba Inc. All rights reserved.

Copyright (c) 2007-2008, Agent Zhang (agentzh). All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

=over

=item *

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

=item *

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

=item *

Neither the name of the Yahoo! China EEEE Works, Alibaba Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

=back

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=head1 SEE ALSO

L<OpenResty::Spec::Overview>, L<openresty>, L<OpenResty::Spec::REST_cn>, L<OpenResty::CheatSheet>, L<WWW::OpenResty>, L<WWW::OpenResty::Simple>.

