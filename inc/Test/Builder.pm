#line 1
package Test::Builder;

use 5.006;
use strict;

our $VERSION = '0.80';
$VERSION = eval { $VERSION }; # make the alpha version come out as a number

# Make Test::Builder thread-safe for ithreads.
BEGIN {
    use Config;
    # Load threads::shared when threads are turned on.
    # 5.8.0's threads are so busted we no longer support them.
    if( $] >= 5.008001 && $Config{useithreads} && $INC{'threads.pm'}) {
        require threads::shared;

        # Hack around YET ANOTHER threads::shared bug.  It would 
        # occassionally forget the contents of the variable when sharing it.
        # So we first copy the data, then share, then put our copy back.
        *share = sub (\[$@%]) {
            my $type = ref $_[0];
            my $data;

            if( $type eq 'HASH' ) {
                %$data = %{$_[0]};
            }
            elsif( $type eq 'ARRAY' ) {
                @$data = @{$_[0]};
            }
            elsif( $type eq 'SCALAR' ) {
                $$data = ${$_[0]};
            }
            else {
                die("Unknown type: ".$type);
            }

            $_[0] = &threads::shared::share($_[0]);

            if( $type eq 'HASH' ) {
                %{$_[0]} = %$data;
            }
            elsif( $type eq 'ARRAY' ) {
                @{$_[0]} = @$data;
            }
            elsif( $type eq 'SCALAR' ) {
                ${$_[0]} = $$data;
            }
            else {
                die("Unknown type: ".$type);
            }

            return $_[0];
        };
    }
    # 5.8.0's threads::shared is busted when threads are off
    # and earlier Perls just don't have that module at all.
    else {
        *share = sub { return $_[0] };
        *lock  = sub { 0 };
    }
}


#line 110

my $Test = Test::Builder->new;
sub new {
    my($class) = shift;
    $Test ||= $class->create;
    return $Test;
}


#line 132

sub create {
    my $class = shift;

    my $self = bless {}, $class;
    $self->reset;

    return $self;
}

#line 151

use vars qw($Level);

sub reset {
    my ($self) = @_;

    # We leave this a global because it has to be localized and localizing
    # hash keys is just asking for pain.  Also, it was documented.
    $Level = 1;

    $self->{Have_Plan}    = 0;
    $self->{No_Plan}      = 0;
    $self->{Original_Pid} = $$;

    share($self->{Curr_Test});
    $self->{Curr_Test}    = 0;
    $self->{Test_Results} = &share([]);

    $self->{Exported_To}    = undef;
    $self->{Expected_Tests} = 0;

    $self->{Skip_All}   = 0;

    $self->{Use_Nums}   = 1;

    $self->{No_Header}  = 0;
    $self->{No_Ending}  = 0;

    $self->{TODO}       = undef;

    $self->_dup_stdhandles unless $^C;

    return;
}

#line 207

sub plan {
    my($self, $cmd, $arg) = @_;

    return unless $cmd;

    local $Level = $Level + 1;

    if( $self->{Have_Plan} ) {
        $self->croak("You tried to plan twice");
    }

    if( $cmd eq 'no_plan' ) {
        $self->no_plan;
    }
    elsif( $cmd eq 'skip_all' ) {
        return $self->skip_all($arg);
    }
    elsif( $cmd eq 'tests' ) {
        if( $arg ) {
            local $Level = $Level + 1;
            return $self->expected_tests($arg);
        }
        elsif( !defined $arg ) {
            $self->croak("Got an undefined number of tests");
        }
        elsif( !$arg ) {
            $self->croak("You said to run 0 tests");
        }
    }
    else {
        my @args = grep { defined } ($cmd, $arg);
        $self->croak("plan() doesn't understand @args");
    }

    return 1;
}

#line 254

sub expected_tests {
    my $self = shift;
    my($max) = @_;

    if( @_ ) {
        $self->croak("Number of tests must be a positive integer.  You gave it '$max'")
          unless $max =~ /^\+?\d+$/ and $max > 0;

        $self->{Expected_Tests} = $max;
        $self->{Have_Plan}      = 1;

        $self->_print("1..$max\n") unless $self->no_header;
    }
    return $self->{Expected_Tests};
}


#line 279

sub no_plan {
    my $self = shift;

    $self->{No_Plan}   = 1;
    $self->{Have_Plan} = 1;
}

#line 294

sub has_plan {
    my $self = shift;

    return($self->{Expected_Tests}) if $self->{Expected_Tests};
    return('no_plan') if $self->{No_Plan};
    return(undef);
};


#line 312

sub skip_all {
    my($self, $reason) = @_;

    my $out = "1..0";
    $out .= " # Skip $reason" if $reason;
    $out .= "\n";

    $self->{Skip_All} = 1;

    $self->_print($out) unless $self->no_header;
    exit(0);
}


#line 339

sub exported_to {
    my($self, $pack) = @_;

    if( defined $pack ) {
        $self->{Exported_To} = $pack;
    }
    return $self->{Exported_To};
}

#line 369

sub ok {
    my($self, $test, $name) = @_;

    # $test might contain an object which we don't want to accidentally
    # store, so we turn it into a boolean.
    $test = $test ? 1 : 0;

    $self->_plan_check;

    lock $self->{Curr_Test};
    $self->{Curr_Test}++;

    # In case $name is a string overloaded object, force it to stringify.
    $self->_unoverload_str(\$name);

    $self->diag(<<ERR) if defined $name and $name =~ /^[\d\s]+$/;
    You named your test '$name'.  You shouldn't use numbers for your test names.
    Very confusing.
ERR

    my $todo = $self->todo();
    
    # Capture the value of $TODO for the rest of this ok() call
    # so it can more easily be found by other routines.
    local $self->{TODO} = $todo;

    $self->_unoverload_str(\$todo);

    my $out;
    my $result = &share({});

    unless( $test ) {
        $out .= "not ";
        @$result{ 'ok', 'actual_ok' } = ( ( $todo ? 1 : 0 ), 0 );
    }
    else {
        @$result{ 'ok', 'actual_ok' } = ( 1, $test );
    }

    $out .= "ok";
    $out .= " $self->{Curr_Test}" if $self->use_numbers;

    if( defined $name ) {
        $name =~ s|#|\\#|g;     # # in a name can confuse Test::Harness.
        $out   .= " - $name";
        $result->{name} = $name;
    }
    else {
        $result->{name} = '';
    }

    if( $todo ) {
        $out   .= " # TODO $todo";
        $result->{reason} = $todo;
        $result->{type}   = 'todo';
    }
    else {
        $result->{reason} = '';
        $result->{type}   = '';
    }

    $self->{Test_Results}[$self->{Curr_Test}-1] = $result;
    $out .= "\n";

    $self->_print($out);

    unless( $test ) {
        my $msg = $todo ? "Failed (TODO)" : "Failed";
        $self->_print_diag("\n") if $ENV{HARNESS_ACTIVE};

    my(undef, $file, $line) = $self->caller;
        if( defined $name ) {
            $self->diag(qq[  $msg test '$name'\n]);
            $self->diag(qq[  at $file line $line.\n]);
        }
        else {
            $self->diag(qq[  $msg test at $file line $line.\n]);
        }
    } 

    return $test ? 1 : 0;
}


sub _unoverload {
    my $self  = shift;
    my $type  = shift;

    $self->_try(sub { require overload } ) || return;

    foreach my $thing (@_) {
        if( $self->_is_object($$thing) ) {
            if( my $string_meth = overload::Method($$thing, $type) ) {
                $$thing = $$thing->$string_meth();
            }
        }
    }
}


sub _is_object {
    my($self, $thing) = @_;

    return $self->_try(sub { ref $thing && $thing->isa('UNIVERSAL') }) ? 1 : 0;
}


sub _unoverload_str {
    my $self = shift;

    $self->_unoverload(q[""], @_);
}    

sub _unoverload_num {
    my $self = shift;

    $self->_unoverload('0+', @_);

    for my $val (@_) {
        next unless $self->_is_dualvar($$val);
        $$val = $$val+0;
    }
}


# This is a hack to detect a dualvar such as $!
sub _is_dualvar {
    my($self, $val) = @_;

    local $^W = 0;
    my $numval = $val+0;
    return 1 if $numval != 0 and $numval ne $val;
}



#line 521

sub is_eq {
    my($self, $got, $expect, $name) = @_;
    local $Level = $Level + 1;

    $self->_unoverload_str(\$got, \$expect);

    if( !defined $got || !defined $expect ) {
        # undef only matches undef and nothing else
        my $test = !defined $got && !defined $expect;

        $self->ok($test, $name);
        $self->_is_diag($got, 'eq', $expect) unless $test;
        return $test;
    }

    return $self->cmp_ok($got, 'eq', $expect, $name);
}

sub is_num {
    my($self, $got, $expect, $name) = @_;
    local $Level = $Level + 1;

    $self->_unoverload_num(\$got, \$expect);

    if( !defined $got || !defined $expect ) {
        # undef only matches undef and nothing else
        my $test = !defined $got && !defined $expect;

        $self->ok($test, $name);
        $self->_is_diag($got, '==', $expect) unless $test;
        return $test;
    }

    return $self->cmp_ok($got, '==', $expect, $name);
}

sub _is_diag {
    my($self, $got, $type, $expect) = @_;

    foreach my $val (\$got, \$expect) {
        if( defined $$val ) {
            if( $type eq 'eq' ) {
                # quote and force string context
                $$val = "'$$val'"
            }
            else {
                # force numeric context
                $self->_unoverload_num($val);
            }
        }
        else {
            $$val = 'undef';
        }
    }

    local $Level = $Level + 1;
    return $self->diag(sprintf <<DIAGNOSTIC, $got, $expect);
         got: %s
    expected: %s
DIAGNOSTIC

}    

#line 600

sub isnt_eq {
    my($self, $got, $dont_expect, $name) = @_;
    local $Level = $Level + 1;

    if( !defined $got || !defined $dont_expect ) {
        # undef only matches undef and nothing else
        my $test = defined $got || defined $dont_expect;

        $self->ok($test, $name);
        $self->_cmp_diag($got, 'ne', $dont_expect) unless $test;
        return $test;
    }

    return $self->cmp_ok($got, 'ne', $dont_expect, $name);
}

sub isnt_num {
    my($self, $got, $dont_expect, $name) = @_;
    local $Level = $Level + 1;

    if( !defined $got || !defined $dont_expect ) {
        # undef only matches undef and nothing else
        my $test = defined $got || defined $dont_expect;

        $self->ok($test, $name);
        $self->_cmp_diag($got, '!=', $dont_expect) unless $test;
        return $test;
    }

    return $self->cmp_ok($got, '!=', $dont_expect, $name);
}


#line 652

sub like {
    my($self, $this, $regex, $name) = @_;

    local $Level = $Level + 1;
    $self->_regex_ok($this, $regex, '=~', $name);
}

sub unlike {
    my($self, $this, $regex, $name) = @_;

    local $Level = $Level + 1;
    $self->_regex_ok($this, $regex, '!~', $name);
}


#line 677


my %numeric_cmps = map { ($_, 1) } 
                       ("<",  "<=", ">",  ">=", "==", "!=", "<=>");

sub cmp_ok {
    my($self, $got, $type, $expect, $name) = @_;

    # Treat overloaded objects as numbers if we're asked to do a
    # numeric comparison.
    my $unoverload = $numeric_cmps{$type} ? '_unoverload_num'
                                          : '_unoverload_str';

    $self->$unoverload(\$got, \$expect);


    my $test;
    {
        local($@,$!,$SIG{__DIE__});  # isolate eval

        my $code = $self->_caller_context;

        # Yes, it has to look like this or 5.4.5 won't see the #line 
        # directive.
        # Don't ask me, man, I just work here.
        $test = eval "
$code" . "\$got $type \$expect;";

    }
    local $Level = $Level + 1;
    my $ok = $self->ok($test, $name);

    unless( $ok ) {
        if( $type =~ /^(eq|==)$/ ) {
            $self->_is_diag($got, $type, $expect);
        }
        else {
            $self->_cmp_diag($got, $type, $expect);
        }
    }
    return $ok;
}

sub _cmp_diag {
    my($self, $got, $type, $expect) = @_;
    
    $got    = defined $got    ? "'$got'"    : 'undef';
    $expect = defined $expect ? "'$expect'" : 'undef';
    
    local $Level = $Level + 1;
    return $self->diag(sprintf <<DIAGNOSTIC, $got, $type, $expect);
    %s
        %s
    %s
DIAGNOSTIC
}


sub _caller_context {
    my $self = shift;

    my($pack, $file, $line) = $self->caller(1);

    my $code = '';
    $code .= "#line $line $file\n" if defined $file and defined $line;

    return $code;
}

#line 766

sub BAIL_OUT {
    my($self, $reason) = @_;

    $self->{Bailed_Out} = 1;
    $self->_print("Bail out!  $reason");
    exit 255;
}

#line 779

*BAILOUT = \&BAIL_OUT;


#line 791

sub skip {
    my($self, $why) = @_;
    $why ||= '';
    $self->_unoverload_str(\$why);

    $self->_plan_check;

    lock($self->{Curr_Test});
    $self->{Curr_Test}++;

    $self->{Test_Results}[$self->{Curr_Test}-1] = &share({
        'ok'      => 1,
        actual_ok => 1,
        name      => '',
        type      => 'skip',
        reason    => $why,
    });

    my $out = "ok";
    $out   .= " $self->{Curr_Test}" if $self->use_numbers;
    $out   .= " # skip";
    $out   .= " $why"       if length $why;
    $out   .= "\n";

    $self->_print($out);

    return 1;
}


#line 833

sub todo_skip {
    my($self, $why) = @_;
    $why ||= '';

    $self->_plan_check;

    lock($self->{Curr_Test});
    $self->{Curr_Test}++;

    $self->{Test_Results}[$self->{Curr_Test}-1] = &share({
        'ok'      => 1,
        actual_ok => 0,
        name      => '',
        type      => 'todo_skip',
        reason    => $why,
    });

    my $out = "not ok";
    $out   .= " $self->{Curr_Test}" if $self->use_numbers;
    $out   .= " # TODO & SKIP $why\n";

    $self->_print($out);

    return 1;
}


#line 911


sub maybe_regex {
    my ($self, $regex) = @_;
    my $usable_regex = undef;

    return $usable_regex unless defined $regex;

    my($re, $opts);

    # Check for qr/foo/
    if( _is_qr($regex) ) {
        $usable_regex = $regex;
    }
    # Check for '/foo/' or 'm,foo,'
    elsif( ($re, $opts)        = $regex =~ m{^ /(.*)/ (\w*) $ }sx           or
           (undef, $re, $opts) = $regex =~ m,^ m([^\w\s]) (.+) \1 (\w*) $,sx
         )
    {
        $usable_regex = length $opts ? "(?$opts)$re" : $re;
    }

    return $usable_regex;
}


sub _is_qr {
    my $regex = shift;
    
    # is_regexp() checks for regexes in a robust manner, say if they're
    # blessed.
    return re::is_regexp($regex) if defined &re::is_regexp;
    return ref $regex eq 'Regexp';
}


sub _regex_ok {
    my($self, $this, $regex, $cmp, $name) = @_;

    my $ok = 0;
    my $usable_regex = $self->maybe_regex($regex);
    unless (defined $usable_regex) {
        $ok = $self->ok( 0, $name );
        $self->diag("    '$regex' doesn't look much like a regex to me.");
        return $ok;
    }

    {
        my $test;
        my $code = $self->_caller_context;

        local($@, $!, $SIG{__DIE__}); # isolate eval

        # Yes, it has to look like this or 5.4.5 won't see the #line 
        # directive.
        # Don't ask me, man, I just work here.
        $test = eval "
$code" . q{$test = $this =~ /$usable_regex/ ? 1 : 0};

        $test = !$test if $cmp eq '!~';

        local $Level = $Level + 1;
        $ok = $self->ok( $test, $name );
    }

    unless( $ok ) {
        $this = defined $this ? "'$this'" : 'undef';
        my $match = $cmp eq '=~' ? "doesn't match" : "matches";

        local $Level = $Level + 1;
        $self->diag(sprintf <<DIAGNOSTIC, $this, $match, $regex);
                  %s
    %13s '%s'
DIAGNOSTIC

    }

    return $ok;
}


# I'm not ready to publish this.  It doesn't deal with array return
# values from the code or context.

#line 1009

sub _try {
    my($self, $code) = @_;
    
    local $!;               # eval can mess up $!
    local $@;               # don't set $@ in the test
    local $SIG{__DIE__};    # don't trip an outside DIE handler.
    my $return = eval { $code->() };
    
    return wantarray ? ($return, $@) : $return;
}

#line 1031

sub is_fh {
    my $self = shift;
    my $maybe_fh = shift;
    return 0 unless defined $maybe_fh;

    return 1 if ref $maybe_fh  eq 'GLOB'; # its a glob ref
    return 1 if ref \$maybe_fh eq 'GLOB'; # its a glob

    return eval { $maybe_fh->isa("IO::Handle") } ||
           # 5.5.4's tied() and can() doesn't like getting undef
           eval { (tied($maybe_fh) || '')->can('TIEHANDLE') };
}


#line 1076

sub level {
    my($self, $level) = @_;

    if( defined $level ) {
        $Level = $level;
    }
    return $Level;
}


#line 1109

sub use_numbers {
    my($self, $use_nums) = @_;

    if( defined $use_nums ) {
        $self->{Use_Nums} = $use_nums;
    }
    return $self->{Use_Nums};
}


#line 1143

foreach my $attribute (qw(No_Header No_Ending No_Diag)) {
    my $method = lc $attribute;

    my $code = sub {
        my($self, $no) = @_;

        if( defined $no ) {
            $self->{$attribute} = $no;
        }
        return $self->{$attribute};
    };

    no strict 'refs';   ## no critic
    *{__PACKAGE__.'::'.$method} = $code;
}


#line 1197

sub diag {
    my($self, @msgs) = @_;

    return if $self->no_diag;
    return unless @msgs;

    # Prevent printing headers when compiling (i.e. -c)
    return if $^C;

    # Smash args together like print does.
    # Convert undef to 'undef' so its readable.
    my $msg = join '', map { defined($_) ? $_ : 'undef' } @msgs;

    # Escape each line with a #.
    $msg =~ s/^/# /gm;

    # Stick a newline on the end if it needs it.
    $msg .= "\n" unless $msg =~ /\n\Z/;

    local $Level = $Level + 1;
    $self->_print_diag($msg);

    return 0;
}

#line 1234

sub _print {
    my($self, @msgs) = @_;

    # Prevent printing headers when only compiling.  Mostly for when
    # tests are deparsed with B::Deparse
    return if $^C;

    my $msg = join '', @msgs;

    local($\, $", $,) = (undef, ' ', '');
    my $fh = $self->output;

    # Escape each line after the first with a # so we don't
    # confuse Test::Harness.
    $msg =~ s/\n(.)/\n# $1/sg;

    # Stick a newline on the end if it needs it.
    $msg .= "\n" unless $msg =~ /\n\Z/;

    print $fh $msg;
}

#line 1268

sub _print_diag {
    my $self = shift;

    local($\, $", $,) = (undef, ' ', '');
    my $fh = $self->todo ? $self->todo_output : $self->failure_output;
    print $fh @_;
}    

#line 1305

sub output {
    my($self, $fh) = @_;

    if( defined $fh ) {
        $self->{Out_FH} = $self->_new_fh($fh);
    }
    return $self->{Out_FH};
}

sub failure_output {
    my($self, $fh) = @_;

    if( defined $fh ) {
        $self->{Fail_FH} = $self->_new_fh($fh);
    }
    return $self->{Fail_FH};
}

sub todo_output {
    my($self, $fh) = @_;

    if( defined $fh ) {
        $self->{Todo_FH} = $self->_new_fh($fh);
    }
    return $self->{Todo_FH};
}


sub _new_fh {
    my $self = shift;
    my($file_or_fh) = shift;

    my $fh;
    if( $self->is_fh($file_or_fh) ) {
        $fh = $file_or_fh;
    }
    else {
        open $fh, ">", $file_or_fh or
            $self->croak("Can't open test output log $file_or_fh: $!");
        _autoflush($fh);
    }

    return $fh;
}


sub _autoflush {
    my($fh) = shift;
    my $old_fh = select $fh;
    $| = 1;
    select $old_fh;
}


my($Testout, $Testerr);
sub _dup_stdhandles {
    my $self = shift;

    $self->_open_testhandles;

    # Set everything to unbuffered else plain prints to STDOUT will
    # come out in the wrong order from our own prints.
    _autoflush($Testout);
    _autoflush(\*STDOUT);
    _autoflush($Testerr);
    _autoflush(\*STDERR);

    $self->output        ($Testout);
    $self->failure_output($Testerr);
    $self->todo_output   ($Testout);
}


my $Opened_Testhandles = 0;
sub _open_testhandles {
    my $self = shift;
    
    return if $Opened_Testhandles;
    
    # We dup STDOUT and STDERR so people can change them in their
    # test suites while still getting normal test output.
    open( $Testout, ">&STDOUT") or die "Can't dup STDOUT:  $!";
    open( $Testerr, ">&STDERR") or die "Can't dup STDERR:  $!";

#    $self->_copy_io_layers( \*STDOUT, $Testout );
#    $self->_copy_io_layers( \*STDERR, $Testerr );
    
    $Opened_Testhandles = 1;
}


sub _copy_io_layers {
    my($self, $src, $dst) = @_;
    
    $self->_try(sub {
        require PerlIO;
        my @src_layers = PerlIO::get_layers($src);

        binmode $dst, join " ", map ":$_", @src_layers if @src_layers;
    });
}

#line 1423

sub _message_at_caller {
    my $self = shift;

    local $Level = $Level + 1;
    my($pack, $file, $line) = $self->caller;
    return join("", @_) . " at $file line $line.\n";
}

sub carp {
    my $self = shift;
    warn $self->_message_at_caller(@_);
}

sub croak {
    my $self = shift;
    die $self->_message_at_caller(@_);
}

sub _plan_check {
    my $self = shift;

    unless( $self->{Have_Plan} ) {
        local $Level = $Level + 2;
        $self->croak("You tried to run a test without a plan");
    }
}

#line 1471

sub current_test {
    my($self, $num) = @_;

    lock($self->{Curr_Test});
    if( defined $num ) {
        unless( $self->{Have_Plan} ) {
            $self->croak("Can't change the current test number without a plan!");
        }

        $self->{Curr_Test} = $num;

        # If the test counter is being pushed forward fill in the details.
        my $test_results = $self->{Test_Results};
        if( $num > @$test_results ) {
            my $start = @$test_results ? @$test_results : 0;
            for ($start..$num-1) {
                $test_results->[$_] = &share({
                    'ok'      => 1, 
                    actual_ok => undef, 
                    reason    => 'incrementing test number', 
                    type      => 'unknown', 
                    name      => undef 
                });
            }
        }
        # If backward, wipe history.  Its their funeral.
        elsif( $num < @$test_results ) {
            $#{$test_results} = $num - 1;
        }
    }
    return $self->{Curr_Test};
}


#line 1516

sub summary {
    my($self) = shift;

    return map { $_->{'ok'} } @{ $self->{Test_Results} };
}

#line 1571

sub details {
    my $self = shift;
    return @{ $self->{Test_Results} };
}

#line 1597

sub todo {
    my($self, $pack) = @_;

    return $self->{TODO} if defined $self->{TODO};

    $pack = $pack || $self->caller(1) || $self->exported_to;
    return 0 unless $pack;

    no strict 'refs';   ## no critic
    return defined ${$pack.'::TODO'} ? ${$pack.'::TODO'}
                                     : 0;
}

#line 1622

sub caller {
    my($self, $height) = @_;
    $height ||= 0;

    my @caller = CORE::caller($self->level + $height + 1);
    return wantarray ? @caller : $caller[0];
}

#line 1634

#line 1648

#'#
sub _sanity_check {
    my $self = shift;

    $self->_whoa($self->{Curr_Test} < 0,  'Says here you ran a negative number of tests!');
    $self->_whoa(!$self->{Have_Plan} and $self->{Curr_Test}, 
          'Somehow your tests ran without a plan!');
    $self->_whoa($self->{Curr_Test} != @{ $self->{Test_Results} },
          'Somehow you got a different number of results than tests ran!');
}

#line 1669

sub _whoa {
    my($self, $check, $desc) = @_;
    if( $check ) {
        local $Level = $Level + 1;
        $self->croak(<<"WHOA");
WHOA!  $desc
This should never happen!  Please contact the author immediately!
WHOA
    }
}

#line 1691

sub _my_exit {
    $? = $_[0];

    return 1;
}


#line 1704

sub _ending {
    my $self = shift;

    my $real_exit_code = $?;
    $self->_sanity_check();

    # Don't bother with an ending if this is a forked copy.  Only the parent
    # should do the ending.
    if( $self->{Original_Pid} != $$ ) {
        return;
    }
    
    # Exit if plan() was never called.  This is so "require Test::Simple" 
    # doesn't puke.
    if( !$self->{Have_Plan} ) {
        return;
    }

    # Don't do an ending if we bailed out.
    if( $self->{Bailed_Out} ) {
        return;
    }

    # Figure out if we passed or failed and print helpful messages.
    my $test_results = $self->{Test_Results};
    if( @$test_results ) {
        # The plan?  We have no plan.
        if( $self->{No_Plan} ) {
            $self->_print("1..$self->{Curr_Test}\n") unless $self->no_header;
            $self->{Expected_Tests} = $self->{Curr_Test};
        }

        # Auto-extended arrays and elements which aren't explicitly
        # filled in with a shared reference will puke under 5.8.0
        # ithreads.  So we have to fill them in by hand. :(
        my $empty_result = &share({});
        for my $idx ( 0..$self->{Expected_Tests}-1 ) {
            $test_results->[$idx] = $empty_result
              unless defined $test_results->[$idx];
        }

        my $num_failed = grep !$_->{'ok'}, 
                              @{$test_results}[0..$self->{Curr_Test}-1];

        my $num_extra = $self->{Curr_Test} - $self->{Expected_Tests};

        if( $num_extra < 0 ) {
            my $s = $self->{Expected_Tests} == 1 ? '' : 's';
            $self->diag(<<"FAIL");
Looks like you planned $self->{Expected_Tests} test$s but only ran $self->{Curr_Test}.
FAIL
        }
        elsif( $num_extra > 0 ) {
            my $s = $self->{Expected_Tests} == 1 ? '' : 's';
            $self->diag(<<"FAIL");
Looks like you planned $self->{Expected_Tests} test$s but ran $num_extra extra.
FAIL
        }

        if ( $num_failed ) {
            my $num_tests = $self->{Curr_Test};
            my $s = $num_failed == 1 ? '' : 's';

            my $qualifier = $num_extra == 0 ? '' : ' run';

            $self->diag(<<"FAIL");
Looks like you failed $num_failed test$s of $num_tests$qualifier.
FAIL
        }

        if( $real_exit_code ) {
            $self->diag(<<"FAIL");
Looks like your test died just after $self->{Curr_Test}.
FAIL

            _my_exit( 255 ) && return;
        }

        my $exit_code;
        if( $num_failed ) {
            $exit_code = $num_failed <= 254 ? $num_failed : 254;
        }
        elsif( $num_extra != 0 ) {
            $exit_code = 255;
        }
        else {
            $exit_code = 0;
        }

        _my_exit( $exit_code ) && return;
    }
    elsif ( $self->{Skip_All} ) {
        _my_exit( 0 ) && return;
    }
    elsif ( $real_exit_code ) {
        $self->diag(<<'FAIL');
Looks like your test died before it could output anything.
FAIL
        _my_exit( 255 ) && return;
    }
    else {
        $self->diag("No tests run!\n");
        _my_exit( 255 ) && return;
    }
}

END {
    $Test->_ending if defined $Test and !$Test->no_ending;
}

#line 1871

1;
