package OpenResty::Shell;

use strict;
use warnings;

use Encode ();
use OpenResty::Shell::History;

eval "use Term::ReadLine;";
if ($@) { die "No Term::ReadLine::Gnu found.\n" };

sub new {
    my ($class, $backend) = @_;
    bless {
        backend => $backend,
    }, $class;
}

sub run {
    my ($self) = @_;
    my $backend = $self->{backend};
    local $| = 1;

    #BEGIN{ $ENV{PERL_RL} = 'GNU' };	# Do not test TR::Gnu !
    my $backend_name = $OpenResty::BackendName;
    my $version = OpenResty->version;
    print <<"_EOC_";
Welcome to openresty $version, the OpenResty interactive terminal.

Type:  \\copyright for distribution terms
       \\a <account> to set the current account
       \\d to view the table list in the current schema
       \\d <table> to view the definition of the specified table
       \\do <sql> to do sql query using xdo
       \\q to quit
       <sql> to do sql query using xquery

_EOC_
    eval { $backend->set_user('_global'); };
    if ($@) { warn $@; }
    my $term = Term::ReadLine->new('Simple Perl calc', \*STDIN, \*STDOUT);
    my $prompt = "$backend_name>";
    my $user = '_admin';
    my $input;
    my $hist = OpenResty::Shell::History->new(
        { file => "$FindBin::Bin/.openresty.shell.hist", term => $term }
    );
    while ( defined ($input = $term->readline($prompt, "")) ) {
        #eval "use Data::Dumper";
        my $cmd = $input;
        #my $cmd = <STDIN>;
        trim($cmd);
        if (lc($cmd) eq '\\q') {
            last;
        }
        elsif (lc($cmd) eq '\\copyright') {
            print <<'_EOC_';
Copyright (c) 2007-2008 by Yahoo! China EEEE Works, Alibaba Inc.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
_EOC_
        }
        elsif ($cmd eq '') { next }
        elsif ($cmd =~ s/^\\[au]\b\s*//) {
            $user = $cmd;
            if ($user) {
                my $res;
                eval {
                    if (my $machine = $backend->has_user($user)) {
                        warn "Switching to account $user on node $machine\n";
                        $res = $backend->set_user($user);
                    } else {
                        die "Account \"$user\" not found.\n";
                    }
                };
                if ($@) { warn $@ }
                if (defined $res) {
                    print $res, "\n";
                }
            } else {
                my @accounts;
                eval {
                    @accounts = $backend->get_all_accounts;
                };
                if ($@) { warn $@ }
                if (@accounts) {
                    my @res;
                    for my $account (@accounts) {
                        my $machine;
                        eval {
                            $machine = $backend->has_user($account);
                        };
                        if ($@) { warn $@ }
                        push @res, { Machine => $machine, Account => $account };
                    }
                    dump_res(\@res);
                } else {
                    warn "No accounts found.\n";
                }
            }
        }
        elsif ($cmd =~ s/^\\d\b\s*//) {
            my $table = $cmd;
            trim($table);
            my $res;
            if ($table) {
                eval {
                    $res = $backend->select(<<_EOC_);
SELECT c.oid,
  n.nspname,
  c.relname
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname ~ '^($table)\$'
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 2, 3;
_EOC_
                    my ($oid);
                    if ($res and @$res) {
                        my $info = $res->[0];
                        $oid = $info->[0];
                        print "** Table $info->[1].$info->[2] **\n";
                    }
                    $res = $backend->select(<<_EOC_, { use_hash => 1 });
SELECT a.attname as "Column",
  pg_catalog.format_type(a.atttypid, a.atttypmod) as "Type",
  (SELECT substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128)
   FROM pg_catalog.pg_attrdef d
   WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef) as "Modifiers",
  a.attnotnull as "Not Null", a.attnum as "ID"
FROM pg_catalog.pg_attribute a
WHERE a.attrelid = '$oid' AND a.attnum > 0 AND NOT a.attisdropped
ORDER BY a.attnum
_EOC_
                };
            } else {
                my $sql = <<'_EOC_';
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' END as "Type",
  r.rolname as "Owner"
FROM pg_catalog.pg_class c
     JOIN pg_catalog.pg_roles r ON r.oid = c.relowner
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','v','S','')
      AND n.nspname NOT IN ('pg_catalog', 'pg_toast')
  AND pg_catalog.pg_table_is_visible(c.oid)
ORDER BY 1,2;
_EOC_
                eval {
                    $res = $backend->select($sql, { use_hash => 1 });
                };
            }
            if ($@) { warn $@ }
            dump_res($res);
        }
        elsif ($cmd =~ s/^\\do\b\s*//) {
            my $sql = $cmd;
            trim($sql);
            my $res;
            eval { $res = $backend->do($sql); };
            if ($@) { warn $@ }
            print $res;
        }
        elsif ($cmd =~ /^\\\S+/) {
            warn "Unknown command: $&\n";
        }
        elsif (lc($cmd) eq 'quit' or lc($cmd) eq 'exit') {
            last;
        }
        else {
            my $res;
            eval { $res = $backend->select($cmd, { use_hash => 1 }); };
            if ($@) { warn $@ }
            dump_res($res);
        }
    } continue {
        $hist->add_history($input);
    }
}

sub trim {
    $_[0] =~ s/^\s+|\s+$//gs;
}

sub dump_res {
    my ($res) = @_;
    return if !defined $res;
    require Text::Table;
    my $tb;
    if (ref $res && @$res) {
        my @keys = sort keys %{ $res->[0] };
        $tb = Text::Table->new(@keys);
    } else {
        print "[]\n";
        return;
    }
    for my $line (@$res) {
        my @items;
        for my $key (sort keys %$line) {
            push @items, $line->{$key};
        }
        $tb->add(@items);
    }
    print "\n",
        $tb->rule('-'),
        $tb->title,
        $tb->rule('-'),
        Encode::encode('utf8', $tb->body),
        $tb->rule('-'),
        "\n";
}

1;
