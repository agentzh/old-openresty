use strict;
use warnings;

package t::miniSQL;

use OpenAPI::miniSQL;

use Test::More qw(no_plan);
use Data::Dumper;

sub import() {
    no strict 'refs';
    *{caller()."::test"} = \&test;
    *{caller()."::rule"} = \&rule;
    *{caller()."::AUTOLOAD"} = \&AUTOLOAD;
}

sub rule(@) {
    my ($rule, $in) = @_;
    no strict 'refs';
    my $r = *{"OpenAPI::miniSQL::$rule"};
    return $r->("OpenAPI::miniSQL", $in);
}

sub rule_capture(@) {
    return rule(@_)->();
}

sub AUTOLOAD {
    no strict 'refs';
    if (${__PACKAGE__."::AUTOLOAD"} =~ m/::([^:]+)$/) {
        unshift @_, $1;
        goto &rule_capture;
    }
}

sub test(@) {    
    my ($rule, $in, $expect) = @_;
    #my $prefix = "\n".("#" x 30)."\n";
    my $prefix = "\n";
    cmp_ok $prefix.Dumper(rule($rule, $in)->()), 'eq', $prefix.Dumper($expect);
}

1;
