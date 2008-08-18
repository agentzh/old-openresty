package OpenResty::QuasiQuote::Validator::Compiler;
use Parse::RecDescent;

{ my $ERRORS;


package Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler;
use strict;
use vars qw($skip $AUTOLOAD  );
$skip = '\s*';


{
local $SIG{__WARN__} = sub {0};
# PRETEND TO BE IN Parse::RecDescent NAMESPACE
*Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::AUTOLOAD	= sub
{
	no strict 'refs';
	$AUTOLOAD =~ s/^Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler/Parse::RecDescent/;
	goto &{$AUTOLOAD};
}
}

push @Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::ISA, 'Parse::RecDescent';
# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::scalar
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"scalar"};
	
	Parse::RecDescent::_trace(q{Trying rule: [scalar]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{scalar},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [type <commit> attr]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{scalar});
		%item = (__RULE__ => q{scalar});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [type]},
				  Parse::RecDescent::_tracefirst($text),
				  q{scalar},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::type($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [type]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{scalar},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [type]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{type}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [attr]},
				  Parse::RecDescent::_tracefirst($text),
				  q{scalar},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{attr})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::attr, 0, 100000000, $_noactions,$expectation,undef))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [attr]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{scalar},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [attr]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{attr(s?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
        my $attrs = { map { @$_ } @{ $item[3] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $code;
        my $code2 = $item[1];
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            $required = 1;
        }

        if (my $args = delete $attrs->{match}) {
            my ($pat, $desc) = @$args;
            $desc = eval $desc;
            $code2 .= "$pat or die qq{Invalid value$for_topic: $desc expected.\\n};\n";
        }

        if (delete $attrs->{nonempty}) {
            $code2 .= "length or die qq{Invalid value$for_topic: Nonempty scalar expected.\\n};\n";
        }

        if (my $args = delete $attrs->{allowed}) {
            my $values = join ', ', @$args;
            my $expr = join ' or ', map { "\$_ eq $_" } @$args;
            $code2 .= "$expr or die qq{Invalid value$for_topic: Allowed values are $values.\\n};\n";
        }

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }
        if (my $args = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required scalar cannot take default value at the same time.\n";
            }
            my $default = $args->[0] or die "validator: :default attribute takes one argument.\n";
            $code .= <<"_EOC_";
else {
\$_ = $default;
}
_EOC_
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "validator: Bad attribute for scalar: ", join(" ", keys %$attrs), "\n";
        }

        #$code . $code2;
        $code;
    };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [type <commit> attr]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{scalar},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{scalar},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{scalar},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{scalar},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::variable
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"variable"};
	
	Parse::RecDescent::_trace(q{Trying rule: [variable]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{variable},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{variable},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{variable});
		%item = (__RULE__ => q{variable});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{variable},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { Text::Balanced::extract_variable($text) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{variable},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{variable},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{variable},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{variable},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{variable},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::value
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"value"};
	
	Parse::RecDescent::_trace(q{Trying rule: [value]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{value},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [hash]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{value});
		%item = (__RULE__ => q{value});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [hash]},
				  Parse::RecDescent::_tracefirst($text),
				  q{value},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::hash($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [hash]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{value},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [hash]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{hash}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [hash]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [array]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{value});
		%item = (__RULE__ => q{value});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [array]},
				  Parse::RecDescent::_tracefirst($text),
				  q{value},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::array($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [array]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{value},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [array]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{array}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [array]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [scalar]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{value});
		%item = (__RULE__ => q{value});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [scalar]},
				  Parse::RecDescent::_tracefirst($text),
				  q{value},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::scalar($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [scalar]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{value},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [scalar]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{scalar}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [scalar]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		
		my $_savetext;
		@item = (q{value});
		%item = (__RULE__ => q{value});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{value},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{value},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{value},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{value},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::lhs
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"lhs"};
	
	Parse::RecDescent::_trace(q{Trying rule: [lhs]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{lhs},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [variable '~~']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{lhs});
		%item = (__RULE__ => q{lhs});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [variable]},
				  Parse::RecDescent::_tracefirst($text),
				  q{lhs},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::variable($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [variable]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{lhs},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [variable]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{variable}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['~~']},
					  Parse::RecDescent::_tracefirst($text),
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'~~'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\~\~//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { "{\nlocal *_ = \\( $item[1] );\n" };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [variable '~~']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{lhs},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{lhs},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{lhs},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{lhs},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::attr
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"attr"};
	
	Parse::RecDescent::_trace(q{Trying rule: [attr]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [':' ident '(' <commit> <leftop: argument /,/ argument> ')']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{attr});
		%item = (__RULE__ => q{attr});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [':']},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\://)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [ident]},
				  Parse::RecDescent::_tracefirst($text),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{ident})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::ident($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ident]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{attr},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ident]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ident}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: ['(']},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'('})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\(//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying operator: [<leftop: argument /,/ argument>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{<leftop: argument /,/ argument>})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [argument]},
				  Parse::RecDescent::_tracefirst($text),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{argument})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::argument($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [argument]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{attr},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [argument]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{argument}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: [/,/]}, Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

			pop @item;
			if (defined $1) {push @item, $item{'argument(s)'}=$1; $backtrack=1;}
			
		Parse::RecDescent::_trace(q{Trying subrule: [argument]},
				  Parse::RecDescent::_tracefirst($text),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{argument})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::argument($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [argument]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{attr},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [argument]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{argument}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  unless (@item) { undef $_tok; last }
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=1)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: argument /,/ argument>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{attr},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: argument /,/ argument>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{'argument(s)'}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying terminal: [')']},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{')'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING3__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { [ $item[2] => [ @{ $item[5] } ] ] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [':' ident '(' <commit> <leftop: argument /,/ argument> ')']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [':' <commit> ident]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{attr});
		%item = (__RULE__ => q{attr});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [':']},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\://)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [ident]},
				  Parse::RecDescent::_tracefirst($text),
				  q{attr},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{ident})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::ident($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ident]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{attr},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ident]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ident}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { [ $item[3] => 1 ] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [':' <commit> ident]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error?:...> <reject>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		
		my $_savetext;
		@item = (q{attr});
		%item = (__RULE__ => q{attr});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error?:...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if ($commit) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{>>Rejecting production<< (found <reject>)},
					 Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		undef $return;
		

		$_tok = undef;
		
		last unless defined $_tok;


		Parse::RecDescent::_trace(q{>>Matched production: [<error?:...> <reject>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{attr},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{attr},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{attr},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{attr},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::ident
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"ident"};
	
	Parse::RecDescent::_trace(q{Trying rule: [ident]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{ident},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/^[A-Za-z]\\w*/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{ident},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{ident});
		%item = (__RULE__ => q{ident});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/^[A-Za-z]\\w*/]}, Parse::RecDescent::_tracefirst($text),
					  q{ident},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:^[A-Za-z]\w*)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/^[A-Za-z]\\w*/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{ident},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{ident},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{ident},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{ident},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{ident},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::key
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"key"};
	
	Parse::RecDescent::_trace(q{Trying rule: [key]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{key},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{key});
		%item = (__RULE__ => q{key});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { extract_delimited($text, '"') };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { eval $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION2__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [ident]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{key});
		%item = (__RULE__ => q{key});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [ident]},
				  Parse::RecDescent::_tracefirst($text),
				  q{key},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::ident($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [ident]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{key},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [ident]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{ident}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [ident]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{key},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{key},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{key},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{key},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::validator
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"validator"};
	
	Parse::RecDescent::_trace(q{Trying rule: [validator]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{validator},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [lhs value <commit> eofile]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{validator});
		%item = (__RULE__ => q{validator});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying repeated subrule: [lhs]},
				  Parse::RecDescent::_tracefirst($text),
				  q{validator},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::lhs, 0, 1, $_noactions,$expectation,undef))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [lhs]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{validator},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [lhs]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{lhs(?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying subrule: [value]},
				  Parse::RecDescent::_tracefirst($text),
				  q{validator},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{value})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::value($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [value]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{validator},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [value]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{value}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [eofile]},
				  Parse::RecDescent::_tracefirst($text),
				  q{validator},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{eofile})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::eofile($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [eofile]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{validator},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [eofile]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{eofile}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { if (@{$item[1]}) {
        $item[1][0] . $item[2] . "}\n";
      } else {
        $item[2]
      }
    };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [lhs value <commit> eofile]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		
		my $_savetext;
		@item = (q{validator});
		%item = (__RULE__ => q{validator});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{validator},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{validator},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{validator},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{validator},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::argument
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"argument"};
	
	Parse::RecDescent::_trace(q{Trying rule: [argument]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{argument},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/^\\d+/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/^\\d+/]}, Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:^\d+)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/^\\d+/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['[]']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['[]']},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\[\]//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['[]']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [variable]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [variable]},
				  Parse::RecDescent::_tracefirst($text),
				  q{argument},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::variable($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [variable]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{argument},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [variable]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{variable}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [variable]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { extract_quotelike($text) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { $item[1] };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION2__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: []},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[4];
		$text = $_[1];
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { extract_codeblock($text) };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { "do $item[1]" };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION2__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: []<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[5];
		
		my $_savetext;
		@item = (q{argument});
		%item = (__RULE__ => q{argument});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{argument},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{argument},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{argument},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{argument},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::array
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"array"};
	
	Parse::RecDescent::_trace(q{Trying rule: [array]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{array},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['[' <commit> array_elem ']' attr]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{array});
		%item = (__RULE__ => q{array});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['[']},
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\[//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [array_elem]},
				  Parse::RecDescent::_tracefirst($text),
				  q{array},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{array_elem})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::array_elem($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [array_elem]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{array},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [array_elem]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{array_elem}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying terminal: [']']},
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{']'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\]//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [attr]},
				  Parse::RecDescent::_tracefirst($text),
				  q{array},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{attr})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::attr, 0, 100000000, $_noactions,$expectation,undef))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [attr]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{array},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [attr]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{attr(s?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
        my $attrs = { map { @$_ } @{ $item[5] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $required;
        my ($code, $code2);
        if ($required = delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            #$required = 1;
        }
        my $code3 = '';
        if (my $args = delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\@\$_ or die qq{Array cannot be empty$for_topic.\\n};
_EOC_
        }

        $code2 .= <<"_EOC_";
ref and ref eq 'ARRAY' or die qq{Invalid value$for_topic: Array expected.\\n};
${code3}for (\@\$_) \{
$item[3]}
_EOC_

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }

        if (my $args = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required array cannot take default value at the same time.\n";
            }
            my $default = $args->[0] or die "validator: :default attribute takes one argument.\n";
            $code .= <<"_EOC_";
else {
\$_ = $default;
}
_EOC_
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "Bad attribute for array: ", join(" ", keys %$attrs), "\n";
        }

        $code;
    };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['[' <commit> array_elem ']' attr]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error?:...> <reject>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		
		my $_savetext;
		@item = (q{array});
		%item = (__RULE__ => q{array});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error?:...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if ($commit) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{>>Rejecting production<< (found <reject>)},
					 Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		undef $return;
		

		$_tok = undef;
		
		last unless defined $_tok;


		Parse::RecDescent::_trace(q{>>Matched production: [<error?:...> <reject>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{array},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{array},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{array},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{array},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::hash
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"hash"};
	
	Parse::RecDescent::_trace(q{Trying rule: [hash]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{hash},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['\{' <commit> <leftop: pair /,/ pair> /,?/ '\}' attr]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{hash});
		%item = (__RULE__ => q{hash});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['\{']},
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\{//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying operator: [<leftop: pair /,/ pair>]},
				  Parse::RecDescent::_tracefirst($text),
				  q{hash},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{<leftop: pair /,/ pair>})->at($text);

		$_tok = undef;
		OPLOOP: while (1)
		{
		  $repcount = 0;
		  my  @item;
		  
		  # MATCH LEFTARG
		  
		Parse::RecDescent::_trace(q{Trying subrule: [pair]},
				  Parse::RecDescent::_tracefirst($text),
				  q{hash},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{pair})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::pair($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [pair]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{hash},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [pair]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{pair}} = $_tok;
		push @item, $_tok;
		
		}


		  $repcount++;

		  my $savetext = $text;
		  my $backtrack;

		  # MATCH (OP RIGHTARG)(s)
		  while ($repcount < 100000000)
		  {
			$backtrack = 0;
			
		Parse::RecDescent::_trace(q{Trying terminal: [/,/]}, Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		

			pop @item;
			if (defined $1) {push @item, $item{'pair(s?)'}=$1; $backtrack=1;}
			
		Parse::RecDescent::_trace(q{Trying subrule: [pair]},
				  Parse::RecDescent::_tracefirst($text),
				  q{hash},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{pair})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::pair($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [pair]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{hash},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [pair]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{pair}} = $_tok;
		push @item, $_tok;
		
		}

			$savetext = $text;
			$repcount++;
		  }
		  $text = $savetext;
		  pop @item if $backtrack;

		  
		  $_tok = [ @item ];
		  last;
		} 

		unless ($repcount>=0)
		{
			Parse::RecDescent::_trace(q{<<Didn't match operator: [<leftop: pair /,/ pair>]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{hash},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched operator: [<leftop: pair /,/ pair>]<< (return value: [}
					  . qq{@{$_tok||[]}} . q{]},
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;

		push @item, $item{'pair(s?)'}=$_tok||[];


		Parse::RecDescent::_trace(q{Trying terminal: [/,?/]}, Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{/,?/})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:,?)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying terminal: ['\}']},
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{'\}'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\}//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING2__}=$&;
		

		Parse::RecDescent::_trace(q{Trying repeated subrule: [attr]},
				  Parse::RecDescent::_tracefirst($text),
				  q{hash},
				  $tracelevel)
					if defined $::RD_TRACE;
		$expectation->is(q{attr})->at($text);
		
		unless (defined ($_tok = $thisparser->_parserepeat($text, \&Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::attr, 0, 100000000, $_noactions,$expectation,undef))) 
		{
			Parse::RecDescent::_trace(q{<<Didn't match repeated subrule: [attr]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{hash},
						  $tracelevel)
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched repeated subrule: [attr]<< (}
					. @$_tok . q{ times)},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{attr(s?)}} = $_tok;
		push @item, $_tok;
		


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
        my $attrs = { map { @$_ } @{ $item[6] } };
        my $pairs = $item[3];
        my $topic = $arg{topic};
        ### $attrs
        my $for_topic = $topic ? " for $topic" : "";
        my ($code, $code2);
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\n};
_EOC_
            $required = 1;
        }
        my $code3 = '';
        if (delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\%\$_ or die qq{Hash cannot be empty$for_topic.\\n};
_EOC_
        }

        $code2 .= <<"_EOC_" . $code3 . join('', map { $_->[1] } @$pairs);
ref and ref eq 'HASH' or die qq{Invalid value$for_topic: Hash expected.\\n};
_EOC_
        my @keys = map { $_->[0] } @$pairs;
        my $cond = join ' or ', map { '$_ eq "' . quotemeta($_) . '"' } @keys;
        $code2 .= <<"_EOC_";
for (keys \%\$_) {
$cond or die qq{Unrecognized key in hash$for_topic: \$_\\n};
}
_EOC_
        if ($required) {
            $code .= $code2
        } else {
            $code .= "if (defined) {\n$code2}\n";
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \$_;\n";
        }

        if (%$attrs) {
            die "Bad attribute for hash: ", join(" ", keys %$attrs), "\n";
        }

        $code;
    };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['\{' <commit> <leftop: pair /,/ pair> /,?/ '\}' attr]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{hash},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{hash},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{hash},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{hash},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::array_elem
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"array_elem"};
	
	Parse::RecDescent::_trace(q{Trying rule: [array_elem]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{array_elem},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [value]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{array_elem},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{array_elem});
		%item = (__RULE__ => q{array_elem});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{array_elem},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
                if ($arg{topic}) {
                    $arg{topic} . " "
                } else {
                    ""
                }
            };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying subrule: [value]},
				  Parse::RecDescent::_tracefirst($text),
				  q{array_elem},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{value})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::value($thisparser,$text,$repeating,$_noactions,sub { return [topic => $item[1] . 'array element'] })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [value]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{array_elem},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [value]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{array_elem},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{value}} = $_tok;
		push @item, $_tok;
		
		}


		Parse::RecDescent::_trace(q{>>Matched production: [value]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{array_elem},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{array_elem},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{array_elem},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{array_elem},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{array_elem},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::pair
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"pair"};
	
	Parse::RecDescent::_trace(q{Trying rule: [pair]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{pair},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [key <commit> ':' value]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{pair});
		%item = (__RULE__ => q{pair});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying subrule: [key]},
				  Parse::RecDescent::_tracefirst($text),
				  q{pair},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::key($thisparser,$text,$repeating,$_noactions,sub { \@arg })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [key]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{pair},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [key]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{key}} = $_tok;
		push @item, $_tok;
		
		}

		

		Parse::RecDescent::_trace(q{Trying directive: [<commit>]},
					Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { $commit = 1 };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{Trying terminal: [':']},
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{':'})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A\://)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying subrule: [value]},
				  Parse::RecDescent::_tracefirst($text),
				  q{pair},
				  $tracelevel)
					if defined $::RD_TRACE;
		if (1) { no strict qw{refs};
		$expectation->is(q{value})->at($text);
		unless (defined ($_tok = Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::value($thisparser,$text,$repeating,$_noactions,sub { return [ topic => qq{"$item[1]"} . ($arg{topic} ? " for $arg{topic}" : '') ] })))
		{
			
			Parse::RecDescent::_trace(q{<<Didn't match subrule: [value]>>},
						  Parse::RecDescent::_tracefirst($text),
						  q{pair},
						  $tracelevel)
							if defined $::RD_TRACE;
			$expectation->failed();
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched subrule: [value]<< (return value: [}
					. $_tok . q{]},
					  
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$item{q{value}} = $_tok;
		push @item, $_tok;
		
		}

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
            my $quoted_key = quotemeta($item[1]);
            [$item[1], <<"_EOC_" . $item[4] . "}\n"]
{
local *_ = \\( \$_->{"$quoted_key"} );
_EOC_
        };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [key <commit> ':' value]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error?:...> <reject>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		
		my $_savetext;
		@item = (q{pair});
		%item = (__RULE__ => q{pair});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error?:...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if ($commit) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		

		Parse::RecDescent::_trace(q{>>Rejecting production<< (found <reject>)},
					 Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		undef $return;
		

		$_tok = undef;
		
		last unless defined $_tok;


		Parse::RecDescent::_trace(q{>>Matched production: [<error?:...> <reject>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{pair},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{pair},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{pair},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{pair},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::eofile
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"eofile"};
	
	Parse::RecDescent::_trace(q{Trying rule: [eofile]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{eofile},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [/^\\Z/]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{eofile},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{eofile});
		%item = (__RULE__ => q{eofile});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: [/^\\Z/]}, Parse::RecDescent::_tracefirst($text),
					  q{eofile},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\A(?:^\Z)//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(q{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;

			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
					if defined $::RD_TRACE;
		push @item, $item{__PATTERN1__}=$&;
		


		Parse::RecDescent::_trace(q{>>Matched production: [/^\\Z/]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{eofile},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{eofile},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{eofile},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{eofile},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{eofile},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}

# ARGS ARE: ($parser, $text; $repeating, $_noactions, \@args)
sub Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler::type
{
	my $thisparser = $_[0];
	use vars q{$tracelevel};
	local $tracelevel = ($tracelevel||0)+1;
	$ERRORS = 0;
	my $thisrule = $thisparser->{"rules"}{"type"};
	
	Parse::RecDescent::_trace(q{Trying rule: [type]},
				  Parse::RecDescent::_tracefirst($_[1]),
				  q{type},
				  $tracelevel)
					if defined $::RD_TRACE;

	
	my $err_at = @{$thisparser->{errors}};

	my $score;
	my $score_return;
	my $_tok;
	my $return = undef;
	my $_matched=0;
	my $commit=0;
	my @item = ();
	my %item = ();
	my $repeating =  defined($_[2]) && $_[2];
	my $_noactions = defined($_[3]) && $_[3];
 	my @arg =        defined $_[4] ? @{ &{$_[4]} } : ();
	my %arg =        ($#arg & 01) ? @arg : (@arg, undef);
	my $text;
	my $lastsep="";
	my $expectation = new Parse::RecDescent::Expectation($thisrule->expected());
	$expectation->at($_[1]);
	
	my $thisline;
	tie $thisline, q{Parse::RecDescent::LineCounter}, \$text, $thisparser;

	

	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['STRING']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[0];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['STRING']},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\ASTRING//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
!ref or die qq{Bad value$for_topic: String expected.\\n};
_EOC_
        };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['STRING']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['INT']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[1];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['INT']},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\AINT//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[-+]?\\d+\$/ or die qq{Bad value$for_topic: Integer expected.\\n};
_EOC_
        };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['INT']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['BOOL']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[2];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['BOOL']},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\ABOOL//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
JSON::XS::is_bool(\$_) or die qq{Bad value$for_topic: Boolean expected.\\n};
_EOC_
        };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['BOOL']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['IDENT']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[3];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['IDENT']},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\AIDENT//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do {
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[A-Za-z]\\w*\$/ or die qq{Bad value$for_topic: Identifier expected.\\n};
_EOC_
        };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['IDENT']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched && !$commit)
	{
		
		Parse::RecDescent::_trace(q{Trying production: ['ANY']},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[4];
		$text = $_[1];
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		Parse::RecDescent::_trace(q{Trying terminal: ['ANY']},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$lastsep = "";
		$expectation->is(q{})->at($text);
		

		unless ($text =~ s/\A($skip)/$lastsep=$1 and ""/e and   $text =~ s/\AANY//)
		{
			
			$expectation->failed();
			Parse::RecDescent::_trace(qq{<<Didn't match terminal>>},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched terminal<< (return value: [}
						. $& . q{])},
						  Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		push @item, $item{__STRING1__}=$&;
		

		Parse::RecDescent::_trace(q{Trying action},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		

		$_tok = ($_noactions) ? 0 : do { '' };
		unless (defined $_tok)
		{
			Parse::RecDescent::_trace(q{<<Didn't match action>> (return value: [undef])})
					if defined $::RD_TRACE;
			last;
		}
		Parse::RecDescent::_trace(q{>>Matched action<< (return value: [}
					  . $_tok . q{])},
					  Parse::RecDescent::_tracefirst($text))
						if defined $::RD_TRACE;
		push @item, $_tok;
		$item{__ACTION1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: ['ANY']<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


	while (!$_matched)
	{
		
		Parse::RecDescent::_trace(q{Trying production: [<error...>]},
					  Parse::RecDescent::_tracefirst($_[1]),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		my $thisprod = $thisrule->{"prods"}[5];
		
		my $_savetext;
		@item = (q{type});
		%item = (__RULE__ => q{type});
		my $repcount = 0;


		

		Parse::RecDescent::_trace(q{Trying directive: [<error...>]},
					Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE; 
		$_tok = do { if (1) { do {
		my $rule = $item[0];
		   $rule =~ s/_/ /g;
		#WAS: Parse::RecDescent::_error("Invalid $rule: " . $expectation->message() ,$thisline);
		push @{$thisparser->{errors}}, ["Invalid $rule: " . $expectation->message() ,$thisline];
		} unless  $_noactions; undef } else {0} };
		if (defined($_tok))
		{
			Parse::RecDescent::_trace(q{>>Matched directive<< (return value: [}
						. $_tok . q{])},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		else
		{
			Parse::RecDescent::_trace(q{<<Didn't match directive>>},
						Parse::RecDescent::_tracefirst($text))
							if defined $::RD_TRACE;
		}
		
		last unless defined $_tok;
		push @item, $item{__DIRECTIVE1__}=$_tok;
		


		Parse::RecDescent::_trace(q{>>Matched production: [<error...>]<<},
					  Parse::RecDescent::_tracefirst($text),
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$_matched = 1;
		last;
	}


        unless ( $_matched || defined($return) || defined($score) )
	{
		

		$_[1] = $text;	# NOT SURE THIS IS NEEDED
		Parse::RecDescent::_trace(q{<<Didn't match rule>>},
					 Parse::RecDescent::_tracefirst($_[1]),
					 q{type},
					 $tracelevel)
					if defined $::RD_TRACE;
		return undef;
	}
	if (!defined($return) && defined($score))
	{
		Parse::RecDescent::_trace(q{>>Accepted scored production<<}, "",
					  q{type},
					  $tracelevel)
						if defined $::RD_TRACE;
		$return = $score_return;
	}
	splice @{$thisparser->{errors}}, $err_at;
	$return = $item[$#item] unless defined $return;
	if (defined $::RD_TRACE)
	{
		Parse::RecDescent::_trace(q{>>Matched rule<< (return value: [} .
					  $return . q{])}, "",
					  q{type},
					  $tracelevel);
		Parse::RecDescent::_trace(q{(consumed: [} .
					  Parse::RecDescent::_tracemax(substr($_[1],0,-length($text))) . q{])}, 
					  Parse::RecDescent::_tracefirst($text),
					  , q{type},
					  $tracelevel)
	}
	$_[1] = $text;
	return $return;
}
}
package OpenResty::QuasiQuote::Validator::Compiler; sub new { my $self = bless( {
                 '_AUTOTREE' => undef,
                 'localvars' => '',
                 'startcode' => '',
                 '_check' => {
                               'thisoffset' => '',
                               'itempos' => '',
                               'prevoffset' => '',
                               'prevline' => '',
                               'prevcolumn' => '',
                               'thiscolumn' => ''
                             },
                 'namespace' => 'Parse::RecDescent::OpenResty::QuasiQuote::Validator::Compiler',
                 '_AUTOACTION' => undef,
                 'rules' => {
                              'scalar' => bless( {
                                                   'impcount' => 0,
                                                   'calls' => [
                                                                'type',
                                                                'attr'
                                                              ],
                                                   'changed' => 0,
                                                   'opcount' => 0,
                                                   'prods' => [
                                                                bless( {
                                                                         'number' => '0',
                                                                         'strcount' => 0,
                                                                         'dircount' => 1,
                                                                         'uncommit' => undef,
                                                                         'error' => undef,
                                                                         'patcount' => 0,
                                                                         'actcount' => 1,
                                                                         'items' => [
                                                                                      bless( {
                                                                                               'subrule' => 'type',
                                                                                               'matchrule' => 0,
                                                                                               'implicit' => undef,
                                                                                               'argcode' => undef,
                                                                                               'lookahead' => 0,
                                                                                               'line' => 84
                                                                                             }, 'Parse::RecDescent::Subrule' ),
                                                                                      bless( {
                                                                                               'hashname' => '__DIRECTIVE1__',
                                                                                               'name' => '<commit>',
                                                                                               'lookahead' => 0,
                                                                                               'line' => 84,
                                                                                               'code' => '$commit = 1'
                                                                                             }, 'Parse::RecDescent::Directive' ),
                                                                                      bless( {
                                                                                               'subrule' => 'attr',
                                                                                               'expected' => undef,
                                                                                               'min' => 0,
                                                                                               'argcode' => undef,
                                                                                               'max' => 100000000,
                                                                                               'matchrule' => 0,
                                                                                               'repspec' => 's?',
                                                                                               'lookahead' => 0,
                                                                                               'line' => 84
                                                                                             }, 'Parse::RecDescent::Repetition' ),
                                                                                      bless( {
                                                                                               'hashname' => '__ACTION1__',
                                                                                               'lookahead' => 0,
                                                                                               'line' => 85,
                                                                                               'code' => '{
        my $attrs = { map { @$_ } @{ $item[3] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $code;
        my $code2 = $item[1];
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\\\n};
_EOC_
            $required = 1;
        }

        if (my $args = delete $attrs->{match}) {
            my ($pat, $desc) = @$args;
            $desc = eval $desc;
            $code2 .= "$pat or die qq{Invalid value$for_topic: $desc expected.\\\\n};\\n";
        }

        if (delete $attrs->{nonempty}) {
            $code2 .= "length or die qq{Invalid value$for_topic: Nonempty scalar expected.\\\\n};\\n";
        }

        if (my $args = delete $attrs->{allowed}) {
            my $values = join \', \', @$args;
            my $expr = join \' or \', map { "\\$_ eq $_" } @$args;
            $code2 .= "$expr or die qq{Invalid value$for_topic: Allowed values are $values.\\\\n};\\n";
        }

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\\n$code2}\\n";
        }
        if (my $args = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required scalar cannot take default value at the same time.\\n";
            }
            my $default = $args->[0] or die "validator: :default attribute takes one argument.\\n";
            $code .= <<"_EOC_";
else {
\\$_ = $default;
}
_EOC_
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \\$_;\\n";
        }

        if (%$attrs) {
            die "validator: Bad attribute for scalar: ", join(" ", keys %$attrs), "\\n";
        }

        #$code . $code2;
        $code;
    }'
                                                                                             }, 'Parse::RecDescent::Action' )
                                                                                    ],
                                                                         'line' => undef
                                                                       }, 'Parse::RecDescent::Production' )
                                                              ],
                                                   'name' => 'scalar',
                                                   'vars' => '',
                                                   'line' => 84
                                                 }, 'Parse::RecDescent::Rule' ),
                              'variable' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 1,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 12,
                                                                                                 'code' => '{ Text::Balanced::extract_variable($text) }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'variable',
                                                     'vars' => '',
                                                     'line' => 12
                                                   }, 'Parse::RecDescent::Rule' ),
                              'value' => bless( {
                                                  'impcount' => 0,
                                                  'calls' => [
                                                               'hash',
                                                               'array',
                                                               'scalar'
                                                             ],
                                                  'changed' => 0,
                                                  'opcount' => 0,
                                                  'prods' => [
                                                               bless( {
                                                                        'number' => '0',
                                                                        'strcount' => 0,
                                                                        'dircount' => 0,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 0,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'subrule' => 'hash',
                                                                                              'matchrule' => 0,
                                                                                              'implicit' => undef,
                                                                                              'argcode' => undef,
                                                                                              'lookahead' => 0,
                                                                                              'line' => 14
                                                                                            }, 'Parse::RecDescent::Subrule' )
                                                                                   ],
                                                                        'line' => undef
                                                                      }, 'Parse::RecDescent::Production' ),
                                                               bless( {
                                                                        'number' => '1',
                                                                        'strcount' => 0,
                                                                        'dircount' => 0,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 0,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'subrule' => 'array',
                                                                                              'matchrule' => 0,
                                                                                              'implicit' => undef,
                                                                                              'argcode' => undef,
                                                                                              'lookahead' => 0,
                                                                                              'line' => 15
                                                                                            }, 'Parse::RecDescent::Subrule' )
                                                                                   ],
                                                                        'line' => 15
                                                                      }, 'Parse::RecDescent::Production' ),
                                                               bless( {
                                                                        'number' => '2',
                                                                        'strcount' => 0,
                                                                        'dircount' => 0,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 0,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'subrule' => 'scalar',
                                                                                              'matchrule' => 0,
                                                                                              'implicit' => undef,
                                                                                              'argcode' => undef,
                                                                                              'lookahead' => 0,
                                                                                              'line' => 16
                                                                                            }, 'Parse::RecDescent::Subrule' )
                                                                                   ],
                                                                        'line' => 16
                                                                      }, 'Parse::RecDescent::Production' ),
                                                               bless( {
                                                                        'number' => '3',
                                                                        'strcount' => 0,
                                                                        'dircount' => 1,
                                                                        'uncommit' => 0,
                                                                        'error' => 1,
                                                                        'patcount' => 0,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'msg' => '',
                                                                                              'hashname' => '__DIRECTIVE1__',
                                                                                              'commitonly' => '',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 17
                                                                                            }, 'Parse::RecDescent::Error' )
                                                                                   ],
                                                                        'line' => 17
                                                                      }, 'Parse::RecDescent::Production' )
                                                             ],
                                                  'name' => 'value',
                                                  'vars' => '',
                                                  'line' => 14
                                                }, 'Parse::RecDescent::Rule' ),
                              'lhs' => bless( {
                                                'impcount' => 0,
                                                'calls' => [
                                                             'variable'
                                                           ],
                                                'changed' => 0,
                                                'opcount' => 0,
                                                'prods' => [
                                                             bless( {
                                                                      'number' => '0',
                                                                      'strcount' => 1,
                                                                      'dircount' => 0,
                                                                      'uncommit' => undef,
                                                                      'error' => undef,
                                                                      'patcount' => 0,
                                                                      'actcount' => 1,
                                                                      'items' => [
                                                                                   bless( {
                                                                                            'subrule' => 'variable',
                                                                                            'matchrule' => 0,
                                                                                            'implicit' => undef,
                                                                                            'argcode' => undef,
                                                                                            'lookahead' => 0,
                                                                                            'line' => 10
                                                                                          }, 'Parse::RecDescent::Subrule' ),
                                                                                   bless( {
                                                                                            'pattern' => '~~',
                                                                                            'hashname' => '__STRING1__',
                                                                                            'description' => '\'~~\'',
                                                                                            'lookahead' => 0,
                                                                                            'line' => 10
                                                                                          }, 'Parse::RecDescent::Literal' ),
                                                                                   bless( {
                                                                                            'hashname' => '__ACTION1__',
                                                                                            'lookahead' => 0,
                                                                                            'line' => 10,
                                                                                            'code' => '{ "{\\nlocal *_ = \\\\( $item[1] );\\n" }'
                                                                                          }, 'Parse::RecDescent::Action' )
                                                                                 ],
                                                                      'line' => undef
                                                                    }, 'Parse::RecDescent::Production' )
                                                           ],
                                                'name' => 'lhs',
                                                'vars' => '',
                                                'line' => 10
                                              }, 'Parse::RecDescent::Rule' ),
                              'attr' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'ident',
                                                              'argument'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 3,
                                                                       'dircount' => 2,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 1,
                                                                       'actcount' => 1,
                                                                       'op' => [],
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => ':',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\':\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 246
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'subrule' => 'ident',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => 246
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'pattern' => '(',
                                                                                             'hashname' => '__STRING2__',
                                                                                             'description' => '\'(\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 246
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 246,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'expected' => '<leftop: argument /,/ argument>',
                                                                                             'min' => 1,
                                                                                             'name' => '\'argument(s)\'',
                                                                                             'max' => 100000000,
                                                                                             'leftarg' => bless( {
                                                                                                                   'subrule' => 'argument',
                                                                                                                   'matchrule' => 0,
                                                                                                                   'implicit' => undef,
                                                                                                                   'argcode' => undef,
                                                                                                                   'lookahead' => 0,
                                                                                                                   'line' => 246
                                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                             'rightarg' => bless( {
                                                                                                                    'subrule' => 'argument',
                                                                                                                    'matchrule' => 0,
                                                                                                                    'implicit' => undef,
                                                                                                                    'argcode' => undef,
                                                                                                                    'lookahead' => 0,
                                                                                                                    'line' => 246
                                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                             'hashname' => '__DIRECTIVE2__',
                                                                                             'type' => 'leftop',
                                                                                             'op' => bless( {
                                                                                                              'pattern' => ',',
                                                                                                              'hashname' => '__PATTERN1__',
                                                                                                              'description' => '/,/',
                                                                                                              'lookahead' => 0,
                                                                                                              'rdelim' => '/',
                                                                                                              'line' => 246,
                                                                                                              'mod' => '',
                                                                                                              'ldelim' => '/'
                                                                                                            }, 'Parse::RecDescent::Token' )
                                                                                           }, 'Parse::RecDescent::Operator' ),
                                                                                    bless( {
                                                                                             'pattern' => ')',
                                                                                             'hashname' => '__STRING3__',
                                                                                             'description' => '\')\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 246
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 247,
                                                                                             'code' => '{ [ $item[2] => [ @{ $item[5] } ] ] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 1,
                                                                       'dircount' => 1,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => ':',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\':\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 248
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 248,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'subrule' => 'ident',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => 248
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 249,
                                                                                             'code' => '{ [ $item[3] => 1 ] }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => 248
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '2',
                                                                       'strcount' => 0,
                                                                       'dircount' => 2,
                                                                       'uncommit' => 0,
                                                                       'error' => 1,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'msg' => '',
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'commitonly' => '?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 250
                                                                                           }, 'Parse::RecDescent::Error' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE2__',
                                                                                             'name' => '<reject>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 250
                                                                                           }, 'Parse::RecDescent::UncondReject' )
                                                                                  ],
                                                                       'line' => 250
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'attr',
                                                 'vars' => '',
                                                 'line' => 246
                                               }, 'Parse::RecDescent::Rule' ),
                              'ident' => bless( {
                                                  'impcount' => 0,
                                                  'calls' => [],
                                                  'changed' => 0,
                                                  'opcount' => 0,
                                                  'prods' => [
                                                               bless( {
                                                                        'number' => '0',
                                                                        'strcount' => 0,
                                                                        'dircount' => 0,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 1,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'pattern' => '^[A-Za-z]\\w*',
                                                                                              'hashname' => '__PATTERN1__',
                                                                                              'description' => '/^[A-Za-z]\\\\w*/',
                                                                                              'lookahead' => 0,
                                                                                              'rdelim' => '/',
                                                                                              'line' => 82,
                                                                                              'mod' => '',
                                                                                              'ldelim' => '/'
                                                                                            }, 'Parse::RecDescent::Token' )
                                                                                   ],
                                                                        'line' => undef
                                                                      }, 'Parse::RecDescent::Production' )
                                                             ],
                                                  'name' => 'ident',
                                                  'vars' => '',
                                                  'line' => 82
                                                }, 'Parse::RecDescent::Rule' ),
                              'key' => bless( {
                                                'impcount' => 0,
                                                'calls' => [
                                                             'ident'
                                                           ],
                                                'changed' => 0,
                                                'opcount' => 0,
                                                'prods' => [
                                                             bless( {
                                                                      'number' => '0',
                                                                      'strcount' => 0,
                                                                      'dircount' => 0,
                                                                      'uncommit' => undef,
                                                                      'error' => undef,
                                                                      'patcount' => 0,
                                                                      'actcount' => 2,
                                                                      'items' => [
                                                                                   bless( {
                                                                                            'hashname' => '__ACTION1__',
                                                                                            'lookahead' => 0,
                                                                                            'line' => 79,
                                                                                            'code' => '{ extract_delimited($text, \'"\') }'
                                                                                          }, 'Parse::RecDescent::Action' ),
                                                                                   bless( {
                                                                                            'hashname' => '__ACTION2__',
                                                                                            'lookahead' => 0,
                                                                                            'line' => 79,
                                                                                            'code' => '{ eval $item[1] }'
                                                                                          }, 'Parse::RecDescent::Action' )
                                                                                 ],
                                                                      'line' => undef
                                                                    }, 'Parse::RecDescent::Production' ),
                                                             bless( {
                                                                      'number' => '1',
                                                                      'strcount' => 0,
                                                                      'dircount' => 0,
                                                                      'uncommit' => undef,
                                                                      'error' => undef,
                                                                      'patcount' => 0,
                                                                      'actcount' => 0,
                                                                      'items' => [
                                                                                   bless( {
                                                                                            'subrule' => 'ident',
                                                                                            'matchrule' => 0,
                                                                                            'implicit' => undef,
                                                                                            'argcode' => undef,
                                                                                            'lookahead' => 0,
                                                                                            'line' => 80
                                                                                          }, 'Parse::RecDescent::Subrule' )
                                                                                 ],
                                                                      'line' => 80
                                                                    }, 'Parse::RecDescent::Production' )
                                                           ],
                                                'name' => 'key',
                                                'vars' => '',
                                                'line' => 79
                                              }, 'Parse::RecDescent::Rule' ),
                              'validator' => bless( {
                                                      'impcount' => 0,
                                                      'calls' => [
                                                                   'lhs',
                                                                   'value',
                                                                   'eofile'
                                                                 ],
                                                      'changed' => 0,
                                                      'opcount' => 0,
                                                      'prods' => [
                                                                   bless( {
                                                                            'number' => '0',
                                                                            'strcount' => 0,
                                                                            'dircount' => 1,
                                                                            'uncommit' => undef,
                                                                            'error' => undef,
                                                                            'patcount' => 0,
                                                                            'actcount' => 1,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'subrule' => 'lhs',
                                                                                                  'expected' => undef,
                                                                                                  'min' => 0,
                                                                                                  'argcode' => undef,
                                                                                                  'max' => 1,
                                                                                                  'matchrule' => 0,
                                                                                                  'repspec' => '?',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 1
                                                                                                }, 'Parse::RecDescent::Repetition' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'value',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 1
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'name' => '<commit>',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 1,
                                                                                                  'code' => '$commit = 1'
                                                                                                }, 'Parse::RecDescent::Directive' ),
                                                                                         bless( {
                                                                                                  'subrule' => 'eofile',
                                                                                                  'matchrule' => 0,
                                                                                                  'implicit' => undef,
                                                                                                  'argcode' => undef,
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 1
                                                                                                }, 'Parse::RecDescent::Subrule' ),
                                                                                         bless( {
                                                                                                  'hashname' => '__ACTION1__',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 2,
                                                                                                  'code' => '{ if (@{$item[1]}) {
        $item[1][0] . $item[2] . "}\\n";
      } else {
        $item[2]
      }
    }'
                                                                                                }, 'Parse::RecDescent::Action' )
                                                                                       ],
                                                                            'line' => undef
                                                                          }, 'Parse::RecDescent::Production' ),
                                                                   bless( {
                                                                            'number' => '1',
                                                                            'strcount' => 0,
                                                                            'dircount' => 1,
                                                                            'uncommit' => 0,
                                                                            'error' => 1,
                                                                            'patcount' => 0,
                                                                            'actcount' => 0,
                                                                            'items' => [
                                                                                         bless( {
                                                                                                  'msg' => '',
                                                                                                  'hashname' => '__DIRECTIVE1__',
                                                                                                  'commitonly' => '',
                                                                                                  'lookahead' => 0,
                                                                                                  'line' => 8
                                                                                                }, 'Parse::RecDescent::Error' )
                                                                                       ],
                                                                            'line' => 8
                                                                          }, 'Parse::RecDescent::Production' )
                                                                 ],
                                                      'name' => 'validator',
                                                      'vars' => '',
                                                      'line' => 1
                                                    }, 'Parse::RecDescent::Rule' ),
                              'argument' => bless( {
                                                     'impcount' => 0,
                                                     'calls' => [
                                                                  'variable'
                                                                ],
                                                     'changed' => 0,
                                                     'opcount' => 0,
                                                     'prods' => [
                                                                  bless( {
                                                                           'number' => '0',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 1,
                                                                           'actcount' => 0,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => '^\\d+',
                                                                                                 'hashname' => '__PATTERN1__',
                                                                                                 'description' => '/^\\\\d+/',
                                                                                                 'lookahead' => 0,
                                                                                                 'rdelim' => '/',
                                                                                                 'line' => 252,
                                                                                                 'mod' => '',
                                                                                                 'ldelim' => '/'
                                                                                               }, 'Parse::RecDescent::Token' )
                                                                                      ],
                                                                           'line' => undef
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '1',
                                                                           'strcount' => 1,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 0,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'pattern' => '[]',
                                                                                                 'hashname' => '__STRING1__',
                                                                                                 'description' => '\'[]\'',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 253
                                                                                               }, 'Parse::RecDescent::Literal' )
                                                                                      ],
                                                                           'line' => 253
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '2',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 0,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'subrule' => 'variable',
                                                                                                 'matchrule' => 0,
                                                                                                 'implicit' => undef,
                                                                                                 'argcode' => undef,
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 254
                                                                                               }, 'Parse::RecDescent::Subrule' )
                                                                                      ],
                                                                           'line' => 254
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '3',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 2,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 255,
                                                                                                 'code' => '{ extract_quotelike($text) }'
                                                                                               }, 'Parse::RecDescent::Action' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION2__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 255,
                                                                                                 'code' => '{ $item[1] }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => 255
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '4',
                                                                           'strcount' => 0,
                                                                           'dircount' => 0,
                                                                           'uncommit' => undef,
                                                                           'error' => undef,
                                                                           'patcount' => 0,
                                                                           'actcount' => 2,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION1__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 256,
                                                                                                 'code' => '{ extract_codeblock($text) }'
                                                                                               }, 'Parse::RecDescent::Action' ),
                                                                                        bless( {
                                                                                                 'hashname' => '__ACTION2__',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 256,
                                                                                                 'code' => '{ "do $item[1]" }'
                                                                                               }, 'Parse::RecDescent::Action' )
                                                                                      ],
                                                                           'line' => 256
                                                                         }, 'Parse::RecDescent::Production' ),
                                                                  bless( {
                                                                           'number' => '5',
                                                                           'strcount' => 0,
                                                                           'dircount' => 1,
                                                                           'uncommit' => 0,
                                                                           'error' => 1,
                                                                           'patcount' => 0,
                                                                           'actcount' => 0,
                                                                           'items' => [
                                                                                        bless( {
                                                                                                 'msg' => '',
                                                                                                 'hashname' => '__DIRECTIVE1__',
                                                                                                 'commitonly' => '',
                                                                                                 'lookahead' => 0,
                                                                                                 'line' => 257
                                                                                               }, 'Parse::RecDescent::Error' )
                                                                                      ],
                                                                           'line' => 257
                                                                         }, 'Parse::RecDescent::Production' )
                                                                ],
                                                     'name' => 'argument',
                                                     'vars' => '',
                                                     'line' => 252
                                                   }, 'Parse::RecDescent::Rule' ),
                              'array' => bless( {
                                                  'impcount' => 0,
                                                  'calls' => [
                                                               'array_elem',
                                                               'attr'
                                                             ],
                                                  'changed' => 0,
                                                  'opcount' => 0,
                                                  'prods' => [
                                                               bless( {
                                                                        'number' => '0',
                                                                        'strcount' => 2,
                                                                        'dircount' => 1,
                                                                        'uncommit' => undef,
                                                                        'error' => undef,
                                                                        'patcount' => 0,
                                                                        'actcount' => 1,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'pattern' => '[',
                                                                                              'hashname' => '__STRING1__',
                                                                                              'description' => '\'[\'',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 145
                                                                                            }, 'Parse::RecDescent::Literal' ),
                                                                                     bless( {
                                                                                              'hashname' => '__DIRECTIVE1__',
                                                                                              'name' => '<commit>',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 145,
                                                                                              'code' => '$commit = 1'
                                                                                            }, 'Parse::RecDescent::Directive' ),
                                                                                     bless( {
                                                                                              'subrule' => 'array_elem',
                                                                                              'matchrule' => 0,
                                                                                              'implicit' => undef,
                                                                                              'argcode' => undef,
                                                                                              'lookahead' => 0,
                                                                                              'line' => 145
                                                                                            }, 'Parse::RecDescent::Subrule' ),
                                                                                     bless( {
                                                                                              'pattern' => ']',
                                                                                              'hashname' => '__STRING2__',
                                                                                              'description' => '\']\'',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 145
                                                                                            }, 'Parse::RecDescent::Literal' ),
                                                                                     bless( {
                                                                                              'subrule' => 'attr',
                                                                                              'expected' => undef,
                                                                                              'min' => 0,
                                                                                              'argcode' => undef,
                                                                                              'max' => 100000000,
                                                                                              'matchrule' => 0,
                                                                                              'repspec' => 's?',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 145
                                                                                            }, 'Parse::RecDescent::Repetition' ),
                                                                                     bless( {
                                                                                              'hashname' => '__ACTION1__',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 146,
                                                                                              'code' => '{
        my $attrs = { map { @$_ } @{ $item[5] } };
        my $topic = $arg{topic};
        my $for_topic = $topic ? " for $topic" : "";
        my $required;
        my ($code, $code2);
        if ($required = delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\\\n};
_EOC_
            #$required = 1;
        }
        my $code3 = \'\';
        if (my $args = delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\\@\\$_ or die qq{Array cannot be empty$for_topic.\\\\n};
_EOC_
        }

        $code2 .= <<"_EOC_";
ref and ref eq \'ARRAY\' or die qq{Invalid value$for_topic: Array expected.\\\\n};
${code3}for (\\@\\$_) \\{
$item[3]}
_EOC_

        if ($required) {
            $code .= $code2;
        } else {
            $code .= "if (defined) {\\n$code2}\\n";
        }

        if (my $args = delete $attrs->{default}) {
            if ($required) {
                die "validator: Required array cannot take default value at the same time.\\n";
            }
            my $default = $args->[0] or die "validator: :default attribute takes one argument.\\n";
            $code .= <<"_EOC_";
else {
\\$_ = $default;
}
_EOC_
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \\$_;\\n";
        }

        if (%$attrs) {
            die "Bad attribute for array: ", join(" ", keys %$attrs), "\\n";
        }

        $code;
    }'
                                                                                            }, 'Parse::RecDescent::Action' )
                                                                                   ],
                                                                        'line' => undef
                                                                      }, 'Parse::RecDescent::Production' ),
                                                               bless( {
                                                                        'number' => '1',
                                                                        'strcount' => 0,
                                                                        'dircount' => 2,
                                                                        'uncommit' => 0,
                                                                        'error' => 1,
                                                                        'patcount' => 0,
                                                                        'actcount' => 0,
                                                                        'items' => [
                                                                                     bless( {
                                                                                              'msg' => '',
                                                                                              'hashname' => '__DIRECTIVE1__',
                                                                                              'commitonly' => '?',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 200
                                                                                            }, 'Parse::RecDescent::Error' ),
                                                                                     bless( {
                                                                                              'hashname' => '__DIRECTIVE2__',
                                                                                              'name' => '<reject>',
                                                                                              'lookahead' => 0,
                                                                                              'line' => 200
                                                                                            }, 'Parse::RecDescent::UncondReject' )
                                                                                   ],
                                                                        'line' => 200
                                                                      }, 'Parse::RecDescent::Production' )
                                                             ],
                                                  'name' => 'array',
                                                  'vars' => '',
                                                  'line' => 145
                                                }, 'Parse::RecDescent::Rule' ),
                              'hash' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'pair',
                                                              'attr'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 2,
                                                                       'dircount' => 2,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 2,
                                                                       'actcount' => 1,
                                                                       'op' => [],
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => '{',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'\\{\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 19
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 19,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'expected' => '<leftop: pair /,/ pair>',
                                                                                             'min' => 0,
                                                                                             'name' => '\'pair(s?)\'',
                                                                                             'max' => 100000000,
                                                                                             'leftarg' => bless( {
                                                                                                                   'subrule' => 'pair',
                                                                                                                   'matchrule' => 0,
                                                                                                                   'implicit' => undef,
                                                                                                                   'argcode' => undef,
                                                                                                                   'lookahead' => 0,
                                                                                                                   'line' => 19
                                                                                                                 }, 'Parse::RecDescent::Subrule' ),
                                                                                             'rightarg' => bless( {
                                                                                                                    'subrule' => 'pair',
                                                                                                                    'matchrule' => 0,
                                                                                                                    'implicit' => undef,
                                                                                                                    'argcode' => undef,
                                                                                                                    'lookahead' => 0,
                                                                                                                    'line' => 19
                                                                                                                  }, 'Parse::RecDescent::Subrule' ),
                                                                                             'hashname' => '__DIRECTIVE2__',
                                                                                             'type' => 'leftop',
                                                                                             'op' => bless( {
                                                                                                              'pattern' => ',',
                                                                                                              'hashname' => '__PATTERN1__',
                                                                                                              'description' => '/,/',
                                                                                                              'lookahead' => 0,
                                                                                                              'rdelim' => '/',
                                                                                                              'line' => 19,
                                                                                                              'mod' => '',
                                                                                                              'ldelim' => '/'
                                                                                                            }, 'Parse::RecDescent::Token' )
                                                                                           }, 'Parse::RecDescent::Operator' ),
                                                                                    bless( {
                                                                                             'pattern' => ',?',
                                                                                             'hashname' => '__PATTERN2__',
                                                                                             'description' => '/,?/',
                                                                                             'lookahead' => 0,
                                                                                             'rdelim' => '/',
                                                                                             'line' => 19,
                                                                                             'mod' => '',
                                                                                             'ldelim' => '/'
                                                                                           }, 'Parse::RecDescent::Token' ),
                                                                                    bless( {
                                                                                             'pattern' => '}',
                                                                                             'hashname' => '__STRING2__',
                                                                                             'description' => '\'\\}\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 19
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'subrule' => 'attr',
                                                                                             'expected' => undef,
                                                                                             'min' => 0,
                                                                                             'argcode' => undef,
                                                                                             'max' => 100000000,
                                                                                             'matchrule' => 0,
                                                                                             'repspec' => 's?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 19
                                                                                           }, 'Parse::RecDescent::Repetition' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 20,
                                                                                             'code' => '{
        my $attrs = { map { @$_ } @{ $item[6] } };
        my $pairs = $item[3];
        my $topic = $arg{topic};
        ### $attrs
        my $for_topic = $topic ? " for $topic" : "";
        my ($code, $code2);
        my $required;
        if (delete $attrs->{required}) {
            $code .= <<"_EOC_";
defined or die qq{Value$for_topic required.\\\\n};
_EOC_
            $required = 1;
        }
        my $code3 = \'\';
        if (delete $attrs->{nonempty}) {
            $code3 .= <<"_EOC_";
\\%\\$_ or die qq{Hash cannot be empty$for_topic.\\\\n};
_EOC_
        }

        $code2 .= <<"_EOC_" . $code3 . join(\'\', map { $_->[1] } @$pairs);
ref and ref eq \'HASH\' or die qq{Invalid value$for_topic: Hash expected.\\\\n};
_EOC_
        my @keys = map { $_->[0] } @$pairs;
        my $cond = join \' or \', map { \'$_ eq "\' . quotemeta($_) . \'"\' } @keys;
        $code2 .= <<"_EOC_";
for (keys \\%\\$_) {
$cond or die qq{Unrecognized key in hash$for_topic: \\$_\\\\n};
}
_EOC_
        if ($required) {
            $code .= $code2
        } else {
            $code .= "if (defined) {\\n$code2}\\n";
        }

        if (my $args = delete $attrs->{to}) {
            my $var = $args->[0];
            $code .= "$var = \\$_;\\n";
        }

        if (%$attrs) {
            die "Bad attribute for hash: ", join(" ", keys %$attrs), "\\n";
        }

        $code;
    }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'hash',
                                                 'vars' => '',
                                                 'line' => 19
                                               }, 'Parse::RecDescent::Rule' ),
                              'array_elem' => bless( {
                                                       'impcount' => 0,
                                                       'calls' => [
                                                                    'value'
                                                                  ],
                                                       'changed' => 0,
                                                       'opcount' => 0,
                                                       'prods' => [
                                                                    bless( {
                                                                             'number' => '0',
                                                                             'strcount' => 0,
                                                                             'dircount' => 0,
                                                                             'uncommit' => undef,
                                                                             'error' => undef,
                                                                             'patcount' => 0,
                                                                             'actcount' => 1,
                                                                             'items' => [
                                                                                          bless( {
                                                                                                   'hashname' => '__ACTION1__',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => 202,
                                                                                                   'code' => '{
                if ($arg{topic}) {
                    $arg{topic} . " "
                } else {
                    ""
                }
            }'
                                                                                                 }, 'Parse::RecDescent::Action' ),
                                                                                          bless( {
                                                                                                   'subrule' => 'value',
                                                                                                   'matchrule' => 0,
                                                                                                   'implicit' => undef,
                                                                                                   'argcode' => '[topic => $item[1] . \'array element\']',
                                                                                                   'lookahead' => 0,
                                                                                                   'line' => 208
                                                                                                 }, 'Parse::RecDescent::Subrule' )
                                                                                        ],
                                                                             'line' => undef
                                                                           }, 'Parse::RecDescent::Production' )
                                                                  ],
                                                       'name' => 'array_elem',
                                                       'vars' => '',
                                                       'line' => 202
                                                     }, 'Parse::RecDescent::Rule' ),
                              'pair' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [
                                                              'key',
                                                              'value'
                                                            ],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 1,
                                                                       'dircount' => 1,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'subrule' => 'key',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => undef,
                                                                                             'lookahead' => 0,
                                                                                             'line' => 69
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'name' => '<commit>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 69,
                                                                                             'code' => '$commit = 1'
                                                                                           }, 'Parse::RecDescent::Directive' ),
                                                                                    bless( {
                                                                                             'pattern' => ':',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\':\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 69
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'subrule' => 'value',
                                                                                             'matchrule' => 0,
                                                                                             'implicit' => undef,
                                                                                             'argcode' => '[ topic => qq{"$item[1]"} . ($arg{topic} ? " for $arg{topic}" : \'\') ]',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 69
                                                                                           }, 'Parse::RecDescent::Subrule' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 70,
                                                                                             'code' => '{
            my $quoted_key = quotemeta($item[1]);
            [$item[1], <<"_EOC_" . $item[4] . "}\\n"]
{
local *_ = \\\\( \\$_->{"$quoted_key"} );
_EOC_
        }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 0,
                                                                       'dircount' => 2,
                                                                       'uncommit' => 0,
                                                                       'error' => 1,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'msg' => '',
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'commitonly' => '?',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 77
                                                                                           }, 'Parse::RecDescent::Error' ),
                                                                                    bless( {
                                                                                             'hashname' => '__DIRECTIVE2__',
                                                                                             'name' => '<reject>',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 77
                                                                                           }, 'Parse::RecDescent::UncondReject' )
                                                                                  ],
                                                                       'line' => 77
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'pair',
                                                 'vars' => '',
                                                 'line' => 69
                                               }, 'Parse::RecDescent::Rule' ),
                              'eofile' => bless( {
                                                   'impcount' => 0,
                                                   'calls' => [],
                                                   'changed' => 0,
                                                   'opcount' => 0,
                                                   'prods' => [
                                                                bless( {
                                                                         'number' => '0',
                                                                         'strcount' => 0,
                                                                         'dircount' => 0,
                                                                         'uncommit' => undef,
                                                                         'error' => undef,
                                                                         'patcount' => 1,
                                                                         'actcount' => 0,
                                                                         'items' => [
                                                                                      bless( {
                                                                                               'pattern' => '^\\Z',
                                                                                               'hashname' => '__PATTERN1__',
                                                                                               'description' => '/^\\\\Z/',
                                                                                               'lookahead' => 0,
                                                                                               'rdelim' => '/',
                                                                                               'line' => 259,
                                                                                               'mod' => '',
                                                                                               'ldelim' => '/'
                                                                                             }, 'Parse::RecDescent::Token' )
                                                                                    ],
                                                                         'line' => undef
                                                                       }, 'Parse::RecDescent::Production' )
                                                              ],
                                                   'name' => 'eofile',
                                                   'vars' => '',
                                                   'line' => 259
                                                 }, 'Parse::RecDescent::Rule' ),
                              'type' => bless( {
                                                 'impcount' => 0,
                                                 'calls' => [],
                                                 'changed' => 0,
                                                 'opcount' => 0,
                                                 'prods' => [
                                                              bless( {
                                                                       'number' => '0',
                                                                       'strcount' => 1,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'STRING',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'STRING\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 210
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 211,
                                                                                             'code' => '{
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
!ref or die qq{Bad value$for_topic: String expected.\\\\n};
_EOC_
        }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => undef
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '1',
                                                                       'strcount' => 1,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'INT',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'INT\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 218
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 219,
                                                                                             'code' => '{
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[-+]?\\\\d+\\$/ or die qq{Bad value$for_topic: Integer expected.\\\\n};
_EOC_
        }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => 218
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '2',
                                                                       'strcount' => 1,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'BOOL',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'BOOL\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 226
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 227,
                                                                                             'code' => '{
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
JSON::XS::is_bool(\\$_) or die qq{Bad value$for_topic: Boolean expected.\\\\n};
_EOC_
        }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => 226
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '3',
                                                                       'strcount' => 1,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'IDENT',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'IDENT\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 234
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 235,
                                                                                             'code' => '{
            my $topic = $arg{topic};
            my $for_topic = $topic ? " for $topic" : "";
            <<"_EOC_";
/^[A-Za-z]\\\\w*\\$/ or die qq{Bad value$for_topic: Identifier expected.\\\\n};
_EOC_
        }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => 234
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '4',
                                                                       'strcount' => 1,
                                                                       'dircount' => 0,
                                                                       'uncommit' => undef,
                                                                       'error' => undef,
                                                                       'patcount' => 0,
                                                                       'actcount' => 1,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'pattern' => 'ANY',
                                                                                             'hashname' => '__STRING1__',
                                                                                             'description' => '\'ANY\'',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 242
                                                                                           }, 'Parse::RecDescent::Literal' ),
                                                                                    bless( {
                                                                                             'hashname' => '__ACTION1__',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 243,
                                                                                             'code' => '{ \'\' }'
                                                                                           }, 'Parse::RecDescent::Action' )
                                                                                  ],
                                                                       'line' => 242
                                                                     }, 'Parse::RecDescent::Production' ),
                                                              bless( {
                                                                       'number' => '5',
                                                                       'strcount' => 0,
                                                                       'dircount' => 1,
                                                                       'uncommit' => 0,
                                                                       'error' => 1,
                                                                       'patcount' => 0,
                                                                       'actcount' => 0,
                                                                       'items' => [
                                                                                    bless( {
                                                                                             'msg' => '',
                                                                                             'hashname' => '__DIRECTIVE1__',
                                                                                             'commitonly' => '',
                                                                                             'lookahead' => 0,
                                                                                             'line' => 244
                                                                                           }, 'Parse::RecDescent::Error' )
                                                                                  ],
                                                                       'line' => 244
                                                                     }, 'Parse::RecDescent::Production' )
                                                            ],
                                                 'name' => 'type',
                                                 'vars' => '',
                                                 'line' => 210
                                               }, 'Parse::RecDescent::Rule' )
                            }
               }, 'Parse::RecDescent' );
}