package t::TestJS;

use strict;
use warnings;

use Data::Dumper;
#use JavaScript;
use JavaScript::SpiderMonkey;
use File::Slurp qw(read_file);

use Test::More;
use Test::LongString;

sub _new {
    my $pkg = shift;
	$pkg = ref $pkg || $pkg;

    my $self = bless {@_}, $pkg;

    my $context = new JavaScript::SpiderMonkey;
    $context->init();
    $self->{context} = $context;

    $self->_init();
    $self->_add_test_methods();

    return $self;
}

sub _init {
    my $self = shift;
    #$self->{context} = $js;
}

sub _add_test_methods {
    my $self = shift;
    my $context = $self->{context};

    $context->function_set( 'todo'    => sub { $Test::More::TODO = $_[0] } );

    $context->function_set( 'plan'    => sub { plan( tests => $_[0] ) } );
    $context->function_set( 'ok'      => sub { ok($_[0], $_[1]) } );
    $context->function_set( 'is'      => sub { is($_[0], $_[1], $_[2]) } );
    $context->function_set( 'is_string'      => sub { is_string($_[0], $_[1], $_[2]) } );
    $context->function_set( 'diag'    => sub { diag(@_) });
    $context->function_set( 'alert'    => sub { diag(@_) });
    $context->function_set( 'dump'    => sub { diag(Dumper(@_)) });
    $context->function_set( 'exit'    => sub { exit });
    $context->function_set( 'include'  =>
        sub {
            my $file = shift;
            my $js = read_file($file);
            $context->eval($js);
        }
    );

    $context->function_set( 'BAIL_OUT' => sub { BAIL_OUT(@_) } );
    $context->function_set( 'sprintf' => sub { sprintf(@_) } );

    $context->eval(<<'end_js'); die $@ if $@;

function throws_ok(fn, match, test) {
  if (!(match && match.exec)) BAIL_OUT("usage: throws_ok( function, match, test )");
  var died = null; try { fn() } catch(e) { died = "" + e };
  if (died) {
    if (match.exec( died )) ok(1, test);
    else {
      diag("error '"+died+"' doesn't match '"+match+"'");
      ok(0, test);
    }
  } else {
    diag("no error thrown");
    ok(0, test);
  }
}

function like( string, match, test ) {
  if (match.exec( string )) {
    ok(1, test);
  } else {
    diag(sprintf("string '%s' doesn't match %s", string, "" + match));
    ok(0, test);
  }
}

function unlike( string, match, test ) {
  if (match.exec( string )) {
    diag(sprintf("string '%s' matches %s", string, match));
    ok(0, test);
  } else {
    ok(1, test);
  }
}

end_js
}

sub import {
  my $class = shift;
  my $args = shift;
  my $self = $class->_new(%$args);
  my $context = $self->{context};

  # Now figure out where we are, and read in the actual test script
  my ($package, $filename, $line) = caller;
  exit unless (-f $filename);
  open my $fh, "<", $filename
    or die "Can't open $filename: $!";
  my $string = "";

  # Read lines up to the line where this import method is called. We
  # replace the content on these lines with newlines rather than discard
  # them entirely, in order to have line numbers matching.
  while (<$fh>) {
    $string .= "\n";
    last if $line == $.
  }

  # .. the rest of the file is assumed to be JavaScript.
  $string .= join "", <$fh>;

  $context->eval($string) or die $@;
  #die "test error: ".$@->as_string if $@;

  exit;
}

1;

