package OpenResty;

our $VERSION = '0.000005';

use strict;
use warnings;

#use Smart::Comments;
use YAML::Syck ();
use JSON::Syck ();

use List::Util qw(first);
use Params::Util qw(_HASH _STRING _ARRAY0 _ARRAY _SCALAR);
use Encode qw(from_to encode decode);
use DBI;

use SQL::Select;
use SQL::Update;
use SQL::Insert;

use OpenResty::Backend;
use OpenResty::Limits;

use MiniSQL::Select;
#use encoding "utf8";

use OpenResty::Util;
use OpenResty::Handler::Model;
use OpenResty::Handler::View;
use OpenResty::Handler::Action;
use OpenResty::Handler::Role;
use OpenResty::Handler::Admin;
use OpenResty::Handler::Login;
use OpenResty::Handler::Captcha;
use OpenResty::Handler::Version;
use Encode::Guess;

$YAML::Syck::ImplicitUnicode = 1;
#$YAML::Syck::ImplicitBinary = 1;

our ($Backend, $BackendName);
our %AccountFiltered;
our $Cache;
our $UUID = Data::UUID->new;

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
    '.js' => \&JSON::Syck::Dump,
    '.json' => \&JSON::Syck::Dump,
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
    '.js' => \&JSON::Syck::Load,
    '.json' => \&JSON::Syck::Load,
);

our $Ext = qr/\.(?:js|json|xml|yaml|yml)/;
our ($Dumper, $Importer);
$Dumper = \&JSON::Syck::Dump;
$Importer = \&JSON::Syck::Load;

# XXX more data types...
sub parse_data {
    shift;
    if (!$Importer) {
        $Importer = \&JSON::Syck::Load;
    }
    return $Importer->($_[0]);
}

sub new {
    my ($class, $cgi) = @_;
    return bless { _cgi => $cgi, _charset => 'UTF-8' }, $class;
}

sub init {
    my ($self, $rurl) = @_;
    my $class = ref $self;
    my $cgi = $self->{_cgi};

    my $db_state = $Backend->state;
    if ($db_state && $db_state =~ /^(?:08|57)/) {
        eval { $Backend->disconnect };
        my $backend = $OpenResty::Config{'backend.type'};
        OpenResty->connect($backend);
        #die "Backend connection lost: ", $db_state, "\n";
    }

    my $as_html = $cgi->url_param('as_html') || 0;
    $self->{_as_html} = $as_html;

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
        from_to($url, $charset, 'UTF-8');
    };

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
        $req_data = $self->parse_data($req_data);
    }

    $self->{_req_data} = $req_data;
}

sub fatal {
    my ($self, $s) = @_;
    $self->error($s);
    $self->response();
}

sub error {
    my ($self, $s) = @_;
    if (!$OpenResty::Config{'frontend.debug'} && $s =~ /^DBD::Pg::(?:db|st) \w+ failed:/) {
        $s = 'Operation failed.';
    }
    $s =~ s/^Syck parser \(line (\d+), column (\d+)\): syntax error at .+/Syntax error found in the JSON input: line $1, column $2./;
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
    my $as_html = $self->{_as_html};
    my $type = $self->{_type} || ($as_html ? 'text/html' : 'text/plain');
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
        $str = $Backend->encode_string($str, $charset);
            #$str = decode('UTF-8', $str);
            #$str = encode($charset, $str);
            #}
    }; #warn $@ if $@;
    if (my $var = $self->{_var} and $Dumper eq \&JSON::Syck::Dump) {
        $str = "$var=$str;";
    } elsif (my $callback = $self->{_callback} and $Dumper eq \&JSON::Syck::Dump) {
        $str = "$callback($str);";
    }
    $str =~ s/\n+$//s;

    if ($as_html) {
        $str = "<html><body><script type=\"text/javascript\">parent.location.hash = ".$Dumper->($str)."</script></body></html>";
    }

    my $meth = $self->{_http_method};
    my $last_res_id = $cgi->url_param('last_response');
    ### $last_res_id;
    ### $meth;
    if (defined $last_res_id) {
        #warn "!!!!!!!!!!!!!!!!!!!!!!!!!!wdy!";
        $Cache->set("lastres:".$last_res_id, $str); # expire in 3 min
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
    $ext ||= '.json';
    $Dumper = $ext2dumper{$ext};
    $Importer = $ext2importer{$ext};
}

sub connect {
    my $self = shift;
    my $name = shift || $BackendName;
    $BackendName = $name;
    $Backend = OpenResty::Backend->new($name);
    #$Backend->select("");
}

sub emit_data {
    my ($self, $data) = @_;
    return $Dumper->($data);
}

sub has_user {
    my ($self, $user) = @_;
    return $Backend->has_user($user);
}

sub add_user {
    my ($self, $user) = @_;
    $Backend->add_user($user);
}

sub drop_user {
    my ($self, $user) = @_;
    $Backend->drop_user($user);
}

sub _IDENT {
    (defined $_[0] && $_[0] =~ /^[A-Za-z]\w*$/) ? $_[0] : undef;
}

sub set_user {
    my ($self, $user) = @_;
    $Backend->set_user($user);
    $self->{_user} = $user;
}

sub current_user {
    my ($self) = @_;
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

OpenResty - General-Purpose Web Services for Web Applications

=head1 DESCRIPTION

=head1 INSTALL

SETUP TEST ENVIRONMENT:

This is a basic guideline for settting up an OpenResty server on your own machine. Someone has succeeded in setting up one on Windows XP using ActivePerl 5.8.8. The normal development environment is Linux though. If you have any particular question, feel free to ask us by sending mails to agentzh@yahoo.cn :)

1. Grab the openresty package and unpack it in some place, let's say it's openresty.

2. Enter the openresty directory, run "perl Makefile.PL" to check missing dependencies:

    $ cd openresty
    $ perl Makefile.PL
    $ sudo make  # This will install missing dependencies

To run "make test" or "make debug", you need to have lighttpd and PostgreSQL database installed.

for PostgreSQL database, you need to prepare a PostgreSQL account (i.e., 'agentzh); and you need to create an empty database (i.e. test), and you need to create a store precedure language plpgsql for that database, contact your PostgreSQL DBA for it or read PostgreSQL manuel.

Basically, they are command like:

    $ createdb test
    $ createuser -P agnetzh
    $ createlang plpgsql test

3. Edit your etc/site_openresty.conf file, change the configure settings
under [backend] section according to your previous settings. The default settings look like this:

    [backend]
    type=Pg
    host=localhost
    user=agentzh
    password=agentzh
    database=test

Most of the time, you need to change the last 3 lines unless you're using exactly the same user, password, and database name.

4. Give read/write access to lighttpd's log file (optional):

    $ chmod 777 /var/log/lighttpd/error.log
    $ chmod 777 /var/log/lighttpd

5. For the Pg backend, one need to create the "anonymous" role in your database (like "test"):

    $ createuser anonymouse test

6. Create a "tester" user account for our test suite in OpenResty (drop it if it already exists):

    $ bin/openresty deluser tester
    $ bin/openresty adduser tester

Give a password (say, blahblahblah) to its Admin role. Update your etc/site_openresty.conf to reflect your these settings:

    [test_suite]
    use_http=0
    server=tester:blahblahblah@localhost

Now you can already run the test suite without a lighttpd server:

    $ prove -Ilib -Iinc -r t

7. Sample lighttpd configuration:

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
                    "OPENAPI_URL_PREFIX" => "",
                    "OPENAPI_COMMAND" => "fastcgi",
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

HOW TO TEST ONE SPECIFIC TEST SUITE FILE

It's also possible to debug a simple .t file, for instance,

    make t/01-sanity.t -f dev.mk

Or use prove to test a remote OpenResty server, for example:

    OPENAPI_FRONTEND=10.62.136.86 prove t/0*.t

where 10.62.136.86 is the IP (or hostname or URL) of your OpenResty server
being tested.

To test the Pg cluster rather than the desktop Pg, change your etc/site_openresty.conf:

    [backend]
    type=PgFarm

and also set other items in the same group if necessary.

FOR DEVELOPER:

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

