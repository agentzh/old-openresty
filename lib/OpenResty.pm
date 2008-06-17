package OpenResty;

our $VERSION = '0.003002';

use strict;
use warnings;

#use Smart::Comments;
use Data::UUID;
use YAML::Syck ();
use JSON::XS ();

use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY0 _ARRAY _SCALAR);
use Encode qw(from_to encode decode);
use Data::Structure::Util qw( _utf8_off );
use DBI;

use OpenResty::SQL::Select;
use OpenResty::SQL::Update;
use OpenResty::SQL::Insert;

use OpenResty::Backend;
use OpenResty::Limits;

#use encoding "utf8";

use OpenResty::Util;
use OpenResty::Handler::Model;
use OpenResty::Handler::View;
use OpenResty::Handler::Feed;
use OpenResty::Handler::Action;
use OpenResty::Handler::Role;
use OpenResty::Handler::Admin;
use OpenResty::Handler::Login;
use OpenResty::Handler::Captcha;
use OpenResty::Handler::Version;
use Encode::Guess;

#$YAML::Syck::ImplicitUnicode = 1;
#$YAML::Syck::ImplicitBinary = 1;

our ($Backend, $BackendName);
our %AccountFiltered;
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
    '.js' => sub { $JsonXs->encode($_[0]) },
    '.json' => sub { $JsonXs->encode($_[0]) },
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
    my ($class, $cgi) = @_;
    return bless { _cgi => $cgi, _charset => 'UTF-8' }, $class;
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

    $self->{_use_cookie}  = $cgi->url_param('use_cookie') || 0;
    $self->{_session}  = $cgi->url_param('session');

    my $charset = $cgi->url_param('charset') || 'UTF-8';

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

    $self->{'_var'} = $cgi->url_param('var');
    $self->{'_callback'} = $cgi->url_param('callback');

    my $offset = $cgi->url_param('offset');
    $offset ||= 0;
    if ($offset !~ /^\d+$/) {
        die "Invalid value for the \"offset\" param: $offset\n";
    }
    $self->{_offset} = $offset;

    my $limit = $cgi->url_param('count');
    # limit is an alias for count
    if (!defined $limit) {
        $limit = $cgi->url_param('limit');
    }
    if (!defined $limit) {
        $limit = $MAX_SELECT_LIMIT;
    } else {
        $limit ||= 0;
        if ($limit !~ /^\d+$/) {
            die "Invalid value for the \"count\" param: $limit\n";
        }
        if ($limit > $MAX_SELECT_LIMIT) {
            die "Value too large for the limit param: $limit\n";
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
        $req_data = $cgi->url_param('data');
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
    if (!$OpenResty::Config{'frontend.debug'} && $s =~ /^DBD::Pg::(?:db|st) \w+ failed:/) {
        $s = 'Operation failed.';
    }
    $s =~ s/(.+) at \S+\/OpenResty\.pm line \d+(?:, <DATA> line \d+)?\./Syntax error found in the JSON input: $1./;
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

    my $meth = $self->{_http_method};
    my $last_res_id = $cgi->url_param('last_response');
    ### $last_res_id;
    ### $meth;
    if (defined $last_res_id) {
        #warn "!!!!!!!!!!!!!!!!!!!!!!!!!!wdy!";
        $Cache->set_last_res($last_res_id, $str);
    }
    #warn ">>>>>>>>>>>>Cookies<<<<<<<<<<<<<<: @cookies\n";
    print $cgi->header(
        -type => "$type" . ($type =~ /text/ ? "; charset=$charset" : ""),
        @cookies ? (-cookie => \@cookies) : ()
    );

    print $str, "\n";
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

sub has_role {
    my ($self, $role) = @_;
    return 1 if $role eq 'Admin' or $role eq 'Public'; # shortcut...
    _IDENT($role) or
        die "Bad role name: ", $OpenResty::Dumper->($role), "\n";
    my $select = OpenResty::SQL::Select->new('id')
        ->from('_roles')
        ->where(name => Q($role))
        ->limit(1);
    my $ret;
    eval { $ret = $self->select("$select",)->[0][0]; };
    return $ret;
}

sub current_user_can {
    my ($self, $meth, $bits) = @_;
    my @urls = $bits;
    my $role = $self->{_role};
    my $max_i = @$bits - 1;
    while ($max_i >= 1) {
        my @last_bits = @{ $urls[-1] };
        if ($last_bits[$max_i] ne '~') {
            $last_bits[$max_i] = '~';
            push @urls, \@last_bits;
        }
    } continue { $max_i-- }
    map { $_ = '/=/' . join '/', @$_ } @urls;
    my $or_clause = join ' or ', map { "url = ".Q($_) } @urls;
    my $sql = "select count(*) from _access where role = ".
        Q($role) . " and method = " . Q($meth) . " and ($or_clause);";
    ### $sql
    my $res = $self->select($sql);
    return do { $res->[0][0] };
}

sub has_feed {
    my ($self, $feed) = @_;

    _IDENT($feed) or die "Bad feed name: $feed\n";

    my $select = OpenResty::SQL::Select->new('id')
        ->from('_feeds')
        ->where(name => Q($feed))
        ->limit(1);
    my $ret;
    eval { $ret = $self->select("$select")->[0][0]; };
    return $ret;
}

sub has_view {
    my ($self, $view) = @_;

    _IDENT($view) or die "Bad view name: $view\n";

    if ($Cache->get_has_view($view)) {
        #warn "has model cache HIT\n";
        return 1;
    }
    my $select = OpenResty::SQL::Select->new('id')
        ->from('_views')
        ->where(name => Q($view))
        ->limit(1);
    my $ret;
    eval { $ret = $self->select("$select")->[0][0]; };
    if ($ret) { $Cache->set_has_view($view) }
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
    my $select = OpenResty::SQL::Select->new('id')
        ->from('_models')
        ->where(name => Q($model))
        ->limit(1);
    my $ret;
    eval { $ret = $self->select("$select")->[0][0]; };
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

1;
__END__

=head1 NAME

OpenResty - General-purpose web service platform for web applications

=head1 VERSION

This document describes OpenResty 0.3.2 released on June 3, 2008.

=head1 DESCRIPTION

This module implements the server-side OpenResty web service protocol. It provides scriptable and extensible web services for both server-side and client-side (pure AJAX) web applications.

Currently this module can serve as a public web interface to a distributive or desktop PostgreSQL database system. In particular, it provides roles, models, views, actions, captchas, the minisql language, and many more to the web users.

"Another framework?" No, no, no, not all!

OpenResty is I<not> a web application framework like L<Jifty>. Rather, it can serve as a component in many existing web application frameworks.

We're already running an instance of the OpenResty server on our Yahoo! China's production machines:

L<http://resty.eeeeworks.org/=/version>

And there're several (pure-client-side) web sites alreadying taking advantage of the services:

=over

=item OpenResty's admin site

L<http://resty.eeeeworks.org/admin/>

=item agentzh's blog and EEEE Works' blog

L<http://blog.agentzh.org>

L<http://eeeeworks.org>

=item Yisou BBS

L<http://www.yisou.com/opi/post.html>

=back

This library is still in B<pre-alpha> stage and the API is still in flux. We're just following the "release early, releaes often" guideline. So please check back often ;)

See L<OpenResty::Spec::Overview> for more detailed information.

L<OpenResty::CheatSheet> also provides a good enough summary for the REST interface.

You'll find my slides for the D2 conference interesting as well:

L<http://agentzh.org/misc/openresty-d2.pdf>

=head1 INSTALLATION

This is a basic guideline for settting up an OpenResty server on your own machine. Someone has succeeded in setting up one on Windows XP using ActivePerl 5.8.8. The normal development environment is Linux though. If you have any particular question, feel free to ask us by sending an email to the authors.

=over

=item 1.

Grab the openresty package and unpack it to some place, let's say it's openresty.

=item 2.

Enter the openresty directory, run "perl Makefile.PL" to check missing dependencies:

    $ cd openresty
    $ perl Makefile.PL
    $ sudo make  # This will install missing dependencies
    $ make test  # run the test suite using the PgMocked backend

For the PostgreSQL database, you need to prepare a PostgreSQL account (e.g.
"agentzh"); and you need to create an empty database (e.g., "test"),
and you need to create a stored precedure language named "plpgsql" for that database,
contact your PostgreSQL DBA for it or read the PostgreSQL manual.

Normally, the following commands are used:

    $ createdb test
    $ createuser -P agnetzh
    $ createlang plpgsql test

=item 3.

Edit your F<etc/site_openresty.conf> file, change the configure settings
under [backend] section according to your previous settings. The default settings look like this:

    [backend]
    recording=0
    # You should change the line below to type=Pg or type=PgFarm
    type=PgMocked
    host=localhost
    user=agentzh
    password=agentzh
    database=test

Most of the time, you need to change C<type=PgMocked> to C<type=Pg>, as well as the last 3 lines (unless you're using exactly the same user, password, and database name). The default "PgMocked" backend is a mocked PostgreSQL database which is useful only for testing purposes.

=item 4.

For the Pg backend, one needs to create the "anonymous" role in his database (like "test"):

    $ createuser -r anonymous

You shouldn't grant any permissions to it.

=item 5.

Create a "tester" user account for our test suite in OpenResty (drop it if it already exists):

    $ bin/openresty deluser tester
    $ bin/openresty adduser tester

Give a password (say, "password") to its Admin role. Update your F<etc/site_openresty.conf> to reflect your these settings:

    [test_suite]
    use_http=0
    server=tester:password@localhost

Now you can already run the test suite without a lighttpd server (but with a true Pg backend):

    $ make test

=item 6.

Sample lighttpd configuration:

    # lighttpd.conf

    server.modules              = (
                "mod_fastcgi",
                ...
    )

    fastcgi.server = (
        "/=" => (
            "openresty" => (
                "socket"       => "/tmp/openresty.socket",
                "check-local"  => "disable",
                "bin-path"     => "/PATH/TO/YOUR/bin/openresty",
                "bin-environment" => (
                    "OPENRESTY_URL_PREFIX" => "",
                    "OPENRESTY_COMMAND" => "fastcgi",
                ),
                "min-procs"    => 1,
                "max-procs"    => 5,
                "max-load-per-proc" => 1,
                "idle-timeout" => 20,
            )
        )
    )

And also make sure the following line is commented out:

    # url.access-deny            = ( "~", ".inc" )

=back

HOW TO TEST ONE SPECIFIC TEST SUITE FILE

It's also possible to debug a simple .t file, for instance,

    make t/01-sanity.t -f dev.mk

Or use the OPENRESTY_TEST_SERVER environment to test a remote OpenResty server, for example:

    OPENRESTY_TEST_SERVER=teser:password@10.62.136.86 prove -Ilib -r t

where 10.62.136.86 is the IP (or hostname or URL) of your OpenResty server
being tested.

To test the Pg cluster rather than the desktop Pg, update your F<etc/site_openresty.conf>:

    [backend]
    type=PgFarm

and also set other items in the same group if necessary.

=head1 SOURCE TREE STRUCTURE

    bin/ directory is the where CGI entry openresty located
    doc/ directory containing OpenResty spec
    lib/OpenResty/ directory contain all the code needed to run OpenResty
    lib/OpenResty/OpenResty.pm contain the code stub for OpenResty protocol
    lib/OpenResty/Limits.pm are those hard limits located, we limit the number of different objects (model, row, view etc.) a user could create by default
    lib/OpenResty/Backend contain all the code to initialize OpenResty meta tables and code to access different database, for now we support Postgres stand alone database and 
    PostgreSQL cluster
    lib/OpenResty/Backend/Pg.pm OpenResty PostgreSQL stand alone database access code
    lib/OpenResty/Backend/PgFarm.pm OpenResty PostgreSQL cluster database access code
    lib/OpenResty/Handler contain all handler methods OpenResty supported, these methods are moved from lib/OpenResty.pm due to code refactor; 
                        method name looks like HTTP_METHOD_some_sub_name.
    lib/SQL classes/methods to generate SQL query (in string form), use OO to encapsulate SQL query generation
    lib/SQL/Statement.pm base class
    lib/SQL/Select.pm class and methods to generate SELECT statement
    lib/SQL/Insert.pm class and methods to generate INSERT statement
    lib/SQL/Update.pm class and methods to generate UPDATE statement
    lib/MiniSQL/ directory conatining our mini-sql parser code, now only SELECT support
    t/ directory containing OpenResty test suite, use `make test' to run the test, read above on how to setup test environment

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

=head1 AUTHOR

=over

=item Agent Zhang (agentzh) C<< <agentzh at yahoo.cn> >>

=item Lei Yonghua (leiyh)

=item Laser Henry (laser)

=item Yu Ting (yuting) C<< <yuting at yahoo.cn> >>

=back

For a complete list of the contributors, please see L<http://svn.openfoundry.org/openapi/trunk/AUTHORS>.

=head1 SEE ALSO

L<OpenResty::Spec::Overview>, L<OpenResty::Spec::REST>, L<OpenResty::CheatSheet>, L<WWW::OpenResty>, L<WWW::OpenResty::Simple>.

=head1 License and Copyright

Copyright (c) 2007, 2008 by Yahoo! China EEEE Works, Alibaba Inc.

This module is free software; you can redistribute it and/or
modify it under the Artistic License 2.0.
A copy of this license can be obtained from

L<http://opensource.org/licenses/artistic-license-2.0.php>

THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

