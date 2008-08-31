package OpenResty;

our $VERSION = '0.003021';

use strict;
use warnings;

#use Smart::Comments;
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
our (%AccountFiltered, %UnsafeAccounts);
our $Cache;
our $UUID = Data::UUID->new;

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

our %ext2dumper = (
    '.yml' => \&YAML::Syck::Dump,
    '.yaml' => \&YAML::Syck::Dump,
    '.js' => sub { _utf8_on($_[0]); $JsonXs->encode($_[0]) },
    '.json' => sub { _utf8_on($_[0]); $JsonXs->encode($_[0]) },
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
our ($Dumper, $Importer);
$Dumper = $ext2dumper{'.js'};
$Importer = $ext2importer{'.js'};

sub version {
    (my $ver = $OpenResty::VERSION) =~ s{^(\d+)\.(\d{3})(\d{3})$}{join '.', int($1), int($2), int($3)}e;
    $ver;
}

# XXX more data types...
sub parse_data {
    shift;
    if (!$Importer) {
        $Importer = $ext2importer{'.js'};
    }
    my $data = $Importer->($_[0]);
    _utf8_off($data);
    return $data;
}

sub new {
    my ($class, $cgi, $call_level) = @_;
    return bless {
        _cgi => $cgi,
        _charset => 'UTF-8',
        _call_level => $call_level,
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

    #warn "DB state: $db_state\n";
    if (!$Backend || !$Backend->ping) {
        warn "Re-connecting the database...\n";
        eval { $Backend->disconnect };
        my $backend = $OpenResty::Config{'backend.type'};
        OpenResty->connect($backend);
        #die "Backend connection lost: ", $db_state, "\n";
    }

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
    #            if ($enc ne 'ascii') {
    #                print "line $.: $enc message found: ", $decoder->decode($s), "\n";
    #            }
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
    #$self->{'_method'} = $http_meth;

    #die "#XXXX !!!! $http_meth", Dumper($self);

    my $url = $$rurl;
    eval {
        from_to($url, $charset, 'utf8');
    };
    warn $@ if $@;
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

    print "HTTP/1.1 200 OK\n";
    my $type = $self->{_type} || 'text/plain';
    #warn $s;
    my $str = '';
    if (my $bin_data = $self->{_bin_data}) {
        binmode \*STDOUT;
        print $cgi->header(
            -type => "$type" . ($type =~ /text/ ? "; charset=$charset" : ""),
            @cookies ? (-cookie => \@cookies) : ()
        );
        if (my $callback = $self->{_callback}) {
            chomp($bin_data);
            print "$callback($bin_data);\n";
        } else {
            print $bin_data;
        }
        return;
    }
    if ($self->{_error}) {
        $str = $self->emit_error($self->{_error});
    } elsif ($self->{_data}) {
        my $data = $self->{_data};
        if ($self->{_warning}) {
            $data->{warning} = $self->{_warning};
        }
        $str = $self->emit_data($data);
    }
    #die $charset;
    # XXX if $charset is 'UTF-8' then don't bother decoding and encoding...
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
    #warn $Dumper;
    #warn $ext2dumper{'.js'};
    if (my $var = $self->{_var} and $Dumper eq $ext2dumper{'.js'}) {
        $str = "$var=$str;";
    } elsif (my $callback = $self->{_callback} and $Dumper eq $ext2dumper{'.js'}) {
        $str = "$callback($str);";
    }
    $str =~ s/\n+$//s;

    #my $meth = $self->{_http_method};
    # XXX last_response is deprecated; use _last_response instead
    my $last_res_id = $self->builtin_param('_last_response');
    ### $last_res_id;
    ### $meth;
    if (defined $last_res_id) {
        #warn "!!!!!!!!!!!!!!!!!!!!!!!!!!wdy!";
        $Cache->set_last_res($last_res_id, $str);
    }
    #warn ">>>>>>>>>>>>Cookies<<<<<<<<<<<<<<: @cookies\n";
    if (length($str) < 500 && $use_gzip) {
        undef $use_gzip;
    }
    print $cgi->header(
        -type => "$type" . ($type =~ /text/ ? "; charset=$charset" : ""),
        $use_gzip ? ('-content-encoding' => 'gzip', '-accept-encoding' => 'Vary') : (),
        @cookies ? (-cookie => \@cookies) : ()
    );
    if ($use_gzip) {
        # compress the content part
        print Compress::Zlib::memGzip($str);
    } else {
        print $str, "\n";
    }
}

sub set_formatter {
    my ($self, $ext) = @_;
    $ext ||= '.js';
    $Dumper = $ext2dumper{$ext};
    $Importer = $ext2importer{$ext};
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
    return eval { $Dumper->($data); }
}

sub get_session {
    my ($self) = @_;
    my ($session, $session_from_cookie);
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
    $session = $self->{_session} || $session_from_cookie;
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
    return 1 if $role eq 'Admin' or $role eq 'Public'; # shortcut...
    _IDENT($role) or
        die "Bad role name: ", $OpenResty::Dumper->($role), "\n";

    my $user = $self->current_user;
    if (my $login_meth = $Cache->get_has_role($user, $role)) {
        #warn "has view cache HIT\n";
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
        select id
        from _models
        where name = $model
        limit 1;
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

sub emit_success {
    my $self = shift;
    return $self->emit_data( { success => 1 } );
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

sub builtin_param {
    my ($self, $key) = @_;
    my $cgi = $self->{_cgi};
    if (substr($key, 0, 1) ne '_') {
        die "Builtin param must be preceded by an underscore.\n";
    }
    (my $deprecated = $key) =~ s/^_//;
    return scalar($cgi->url_param($deprecated)) ||
        scalar($cgi->url_param($key));
}

1;
__END__

=encoding utf8

=head1 NAME

OpenResty - General-purpose web service platform for web applications

=head1 VERSION

This document describes OpenResty 0.3.21 released on August 20, 2008.

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

=head1 SOURCE CONTROL

For the very latest version of this module, check out the source from
the SVN repos below:

L<http://svn.openfoundry.org/openapi/trunk>

There is anonymous access to all. If you'd like a commit bit, please let
us know. :)

=head1 TODO

For the project's TODO list, please check out L<http://svn.openfoundry.org/openapi/trunk/TODO>

=head1 BUGS

There must be some serious bugs lurking somewhere given the current status of the implementation and test suite.

Please report bugs or send wish-list to
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=OpenResty>.

=head1 AUTHORS

=over

=item Agent Zhang (agentzh) C<< <agentzh at yahoo dot cn> >>

=item chaoslawful (王晓哲) C<< <chaoslawful at gmail dot com> >>

=item Lei Yonghua (leiyh)

=item Laser Henry (laser) C<< <laserhenry at gmail dot com> >>

=item Yu Ting (yuting) C<< <yuting at yahoo dot cn> >>

=back

For a complete list of the contributors, please see L<http://svn.openfoundry.org/openapi/trunk/AUTHORS>.

=head1 License and Copyright

Copyright (c) 2007, 2008 by Yahoo! China EEEE Works, Alibaba Inc.

This module is free software; you can redistribute it and/or
modify it under the Artistic License 2.0.
A copy of this license can be obtained from

L<http://opensource.org/licenses/artistic-license-2.0.php>

THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=head1 SEE ALSO

L<OpenResty::Spec::Overview>, L<openresty>, L<OpenResty::Spec::REST_cn>, L<OpenResty::CheatSheet>, L<WWW::OpenResty>, L<WWW::OpenResty::Simple>.

