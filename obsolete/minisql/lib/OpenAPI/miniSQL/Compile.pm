#!/usr/bin/perl -w
use strict;
use warnings;

package OpenResty::miniSQL::Compile;

use Module::Compile -base;
use Pugs::Compiler::Grammar;
use Pugs::Runtime::Tracer;
use File::Slurp;


my $debug = 0;
my $safe_mode = 0;
my $debug_dir = './dbg/';

sub import {
    my ($self, %opt) = @_;
    $debug = 1 if $opt{'debug'};
    $safe_mode = 1 if $opt{'safe_mode'};
    $debug_dir = $opt{'debug_dir'} if exists $opt{'debug_dir'};    
    goto &Module::Compile::import;   
}

sub pmc_compile {
    my ($self, $source) = @_;
    # grammar name
    $source =~ m/grammar\s+(.+?);/;
    my $grammar_name = $1;
    # write grammar to a tmp file
    $grammar_name =~ s/::/-/;
    mkdir $debug_dir if not -x $debug_dir and $debug;
    write_file("$debug_dir$grammar_name.grammar", \$source) if $debug;    
    # call the compiler
    my $compiler = Pugs::Compiler::Grammar->compile(
        $source, { safe_mode => $safe_mode } ) or die;
    # return with tracing code if $debug
    return $debug ? expand_tracing_code($compiler->perl5)
                  : $compiler->perl5;
}

1;