package t::TestJS;

use strict;
use warnings;

use Data::Dumper;
#use JavaScript;
use JavaScript::SpiderMonkey;
use File::Slurp qw(read_file);

use Test::More;

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
    $context->function_set( 'diag'    => sub { diag(@_) });
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

__END__
=head1 NAME

Test::JavaScript::More - test javascript code

=head1 SYNOPSIS

  #!/usr/bin/perl
  use Test::JavaScript::More;

  // from here on the script is all JavaScript
  plan(1);

  function foo() { return "foo"; }

  ok( foo(), "returns true" );
  is( foo(), "foo", "more specifically, 'foo'" );

=head1 DESCRIPTION

This module provides Test::More-like function for JavaScript (the
current implementation just imports some of Test::More's functions into
JavaScript space).

Everything below the C<use Test::JavaScript::More> line will be
interpreted as JavaScript. You can subclass this module and set up your
context to include library code.

The line numbers will match up. Any lines in the test file up to and
including the C<use Test::JavaScript::More> are replaced with newlines
in the compiled JavaScript.

=head1 JAVASCRIPT FUNCTIONS

This module exports a bunch lot of functions to JavaScript:

=head2 Testing Functions

=over

=item plan( number_of_tests)

Plan the number of tests.  The same as Test::More's C<plan>.

=item ok( true_or_false, label )

Is this okay?  The same as Test::More's C<ok>.

=item is( value, expected, label )

Is this this?  The same as Test::More's C<is>.

=item diag( string )

Produce some diagnostic output (i.e. text with # in front of it.)  The
same as Test:More's C<diag>.

=item like( string, match, label )

Does this string match the regular expression?

=item unlike( string, match, label )

Does this string not match the regular expression?

=item throws_ok( function, match, label )

Does this function throw an exception that matches this regular expression

=back

=head2 Toto Testing

=over

=item todo( true_or_false )

Set'todo' mode (or not.)  If set to true, all subseqent tests
run now will be todo tests.  You have to manually set this back to false
to stop being in todo being in 'todo' mode.

=back

=head1 BUGS

C<throws_ok>, C<like> and C<unlike> do their diagnostic error messages
the wrong way round.

=head1 AUTHOR

Documentation and original crazy scheme for reading in the caller file
by Mark Fowler. Testing functionality by Tom Insam and Stig Brautaset.
Extracted from an internal Fotango test module by Stig Brautaset and Ash
Berlin.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Fotango and Claes Jakobsson C<< <claesjac@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut
