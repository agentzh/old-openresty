# vi:filetype=

# Tests for the OpenResty::RestyScript module. (Action part)

#use Smart::Comments;

my $skip;
my $ExePath;
BEGIN {
    use FindBin;
    $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
    if (!-f $ExePath) {
        $skip = "$ExePath is not found.\n";
        return;
    }
    if (!-x $ExePath) {
        $skip = "$ExePath is not an executable.\n";
        return;
    }
};
use Test::Base $skip ? (skip_all => $skip) : ();

use lib 'lib';
use OpenResty::RestyScript;

#plan tests => 3 * blocks();

plan 'no_plan';

sub quote {
    my $s = shift;
    if (!defined $s) { $s = '' }
    $s =~ s/\n/{NEW_LINE}/g;
    $s =~ s/\r/{RETURN}/g;
    $s =~ s/\t/{TAB}/g;
    '$y$' . $s . '$y$';
}

sub quote_only {
    my $s = shift;
    if (!defined $s) { $s = '' }
    $s =~ s/\n/{NEW_LINE}/g;
    $s =~ s/\r/{RETURN}/g;
    $s =~ s/\t/{TAB}/g;
    $s
}

sub quote_ident {
    qq/"$_[0]"/
}

run {
    my $block = shift;
    my $name = $block->name;

    my %in_vars;
    my $in_vars = $block->in_vars;
    if (defined $in_vars) {
        my @ln = split /\n+/, $in_vars;
        map {
            my ($var, $val) = split /=/, $_, 2;
            $in_vars{$var} = $val;
        } @ln;
    }

    my $sql = $block->sql or die "$name - No --- sql section found.\n";
    my $view = OpenResty::RestyScript->new('action', $sql);
    my ($frags, $stats);
    eval {
        ($frags, $stats) = $view->compile;
    };
    ### Fragments: $frags
    ### Stats: $stats
    my $res;
    if ($@ && !defined $block->error) { warn $@ }
    elsif (defined $block->error) {
        my $error = $block->error || '';
        $error =~ s/^\s+$//g;
        (my $got = $@) =~ s/^expecting .*\n//ms;
        is $got, $error, "$name - error msg ok";
    }
    #%in_vars,
    my (@models, @cols, @vars, @unbound);
    if ($stats) {
        @models = @{ $stats->{modelList} };
        my @m;
        for my $model (@models) {
            if ($model =~ s/^\$//) {
                if (defined $in_vars{$model}) {
                    push @m, $in_vars{$model};
                } else {
                    push @m, '$'.$model;
                }
            } else {
                push @m, $model;
            }
        }
        @models = @m;
    }
    ### @models
    my $ex_models = $block->models;
    if (defined $ex_models) {
        is join(' ', @models), $block->models, "$name - model list ok";
    }

    # XXX FIX ME
    # for the real action handler, we need to do typechecking in a
    # separate pass. Below is merely a hack regarding type inferencing

    my @out_cmds;
    my $cmds = $frags;

    for my $cmd (@$cmds) {
        croak "Invalid command: ", Dumper($cmd) unless ref $cmd;
        if (@$cmd == 1 and ref $cmd->[0]) {   # being a SQL command
            my $cmd = $cmd->[0];
            ### $cmd

            my @bits;
            my %types;
            for my $frag (@$cmd) {
                if (ref $frag) {  # being a variable
                    my ($var, $type) = @$frag;
                    if ($type eq 'symbol') { $types{$var} = 'symbol' }
                    my $quote = $types{$var} ? \&quote_ident : \&quote;
                    push @vars, $var;
                    if (!defined $in_vars{$var}) {
                        push @unbound, $var;
                        push @bits, $quote->('');
                    } else {
                        push @bits, $quote->($in_vars{$var});
                    }
                } else {
                    push @bits, $frag;
                }
            }
            push @out_cmds, @bits ? (join '', @bits) : '';
        } else { # being an HTTP command
            ### HTTP cmd: $cmd
            my ($http_meth, $url, $content) = @$cmd;
            my @bits = "$http_meth ";
            for my $frag (@$url) {
                if (ref $frag) { # being a variable
                    my ($var) = @$frag; # we ignore the type part here since it should always be "quoted"
                    my $quote = \&quote_only;
                    push @vars, $var;
                    if (!defined $in_vars{$var}) {
                        push @unbound, $var;
                        push @bits, $quote->('');
                    } else {
                        push @bits, $quote->($in_vars{$var});
                    }
                } else {
                    push @bits, $frag;
                }
            }
            if ($http_meth ne 'POST' and $http_meth ne 'PUT' and $content) {
                die "Content part not allowed for $http_meth\n";
            }
            push @bits, ' ';
            for my $frag (@$content) {
                if (ref $frag) { # being a variable
                    my ($var, $type) = @$frag; # type could only be literal or quoted here
                    my $quote = $type eq 'quoted' ? \&quote_only : \&quote_ident;
                    push @vars, $var;
                    if (!defined $in_vars{$var}) {
                        push @unbound, $var;
                        push @bits, $quote->('');
                    } else {
                        push @bits, $quote->($in_vars{$var});
                    }
                } else {
                    push @bits, $frag;
                }
            }
            push @out_cmds, @bits ? (join '', @bits) : '';
        }
    }

    my $out = @out_cmds ? (join "\n", @out_cmds) : '';
    $out =~ s/\s+$//gsm;
    $out =~ s/\n$//g;
    ### $out
    if (defined $block->out) {
        (my $expected = $block->out) =~ s/\n$//g;
        is $out, $expected, "$name - sql emittion ok";
    }
    my $ex_vars = $block->vars;
    if (defined $ex_vars) {
        is join(' ', @vars), $ex_vars, "$name - var list ok";
    }
    my $ex_unbound = $block->unbound;
    if (defined $ex_unbound) {
        is join(' ', @unbound), $ex_unbound, "$name - unbound var list ok";
    }
};

__DATA__

=== TEST 1: Simple
--- sql
select * from
    Carrie; select * from Post
--- error
--- models: Carrie Post
--- out
select * from "Carrie"
select * from "Post"



=== TEST 2: basic delete
--- sql
delete from $foo where $foo > $id;
--- vars: foo foo id
--- models: $foo
--- out
delete from "" where "" > $y$$y$



=== TEST 3: basic delete (with vars)
--- sql
delete from $foo where $foo > $id;
--- vars: foo foo id
--- models: cat
--- in_vars
foo=cat
id=dog
--- out
delete from "cat" where "cat" > $y$dog$y$



=== TEST 4: basic delete
--- sql
delete  from  Foo  where  col>$id;
--- vars: id
--- models: Foo
--- in_vars
id=hello
--- out
delete from "Foo" where "col" > $y$hello$y$



=== TEST 5: basic update
--- sql
update $blah set $foo=$blah+1
--- models: cat
--- vars: blah foo blah
--- in_vars
blah=cat
foo=dog
--- out
update "cat" set "dog" = ("cat" + 1)



=== TEST 6: basic update
--- sql
update Foo set col=col+1
--- models: Foo
--- out
update "Foo" set "col" = ("col" + 1)



=== TEST 7: update with delete
--- sql
update
    Foo set foo = $foo where $foo>$bar and $foo like '%hey' ;
    ;
delete from $foo where $foo=5
 ;
--- in_vars
foo=Cat
bar=Dog
--- out
update "Foo" set "foo" = $y$Cat$y$ where ($y$Cat$y$ > $y$Dog$y$ and $y$Cat$y$ like '%hey')
delete from "Cat" where "Cat" = 5



=== TEST 8: simple GET
--- sql
GET $bah;
--- vars: bah
--- in_vars
bah=/=/version
--- out
GET /=/version



=== TEST 9: GET with expr
--- sql
GET ( '/=/'||$foo) || $foo
--- vars: foo foo
--- out
GET /=/



=== TEST 10: GET with expr (with vars)
--- sql
GET ( '/=/'||$foo) || $foo
--- vars: foo foo
--- in_vars
foo=version/
--- out
GET /=/version/version/



=== TEST 11: GET with expr
--- sql
GET ( '/=/'|| 'ver') || 'sion'
--- out
GET /=/version



=== TEST 12: simple POST
--- sql
POST '/=/model/Post/~/~' || $foo
{ $foo: "hello" || $foo }
--- in_vars
foo=
--- out
POST /=/model/Post/~/~ {"": "hello"}



=== TEST 13: simple POST (nonempty foo)
--- sql
POST '/=/model/Post/~/~' || $foo
{ $foo: "hello" || $foo }
--- in_vars
foo=.json
--- out
POST /=/model/Post/~/~.json {".json": "hello.json"}



=== TEST 14: POST a simple array
--- sql
POST
'/=/model/Post/' || '~/~'
[1,$foo,2.5,"hi"||$foo]
--- in_vars
foo=, world
--- out
POST /=/model/Post/~/~ [1, ", world", 2.5, "hi, world"]



=== TEST 15: PUT a literal
--- sql
PUT '/=/foo' $foo
--- vars: foo
--- models:
--- out
PUT /=/foo ""



=== TEST 16: PUT a hash of lists of hashes
--- sql
POST '/=/model/~'
{ "description": $type,
    "columns": [
        { "name": "name", $type: 'text'},
        { "name":"created",$type:"timestamp (0) with time zone", default: [$type] }
    ]
}
--- vars: type type type type
--- in_vars
type=bigint
--- out
POST /=/model/~ {"description": "bigint", "columns": [{"name": "name", "bigint": "text"}, {"name": "created", "bigint": "timestamp (0) with time zone", "default": ["bigint"]}]}



=== TEST 17: with variables and some noises
--- sql
            update Post
            set comments = comments + 1
            where id = $post_id;
            POST '/=/model/Comment/~/~'
            { "sender": $sender, "body": $body, "$post_id": $post_id };
--- vars: post_id sender body post_id
--- in_vars
post_id=32
sender=agentzh
body=Hello, world!
--- models: Post
--- out
update "Post" set "comments" = ("comments" + 1) where "id" = $y$32$y$
POST /=/model/Comment/~/~ {"sender": "agentzh", "body": "Hello, world!", "$post_id": "32"}



=== TEST 18: try delete
--- sql
DELETE '/=/model' || $foo;
DELETE '/=/view';
DELETE $foo
--- models:
--- vars: foo foo
--- in_vars
foo=/=/hi
--- out
DELETE /=/model/=/hi
DELETE /=/view
DELETE /=/hi

