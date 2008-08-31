package OpenResty::Handler::Base;

use strict;
use warnings;

sub new {
    my ($proto) = @_;
    my $class = ref $proto || $proto;
    bless {
    }, $class;
}

sub go {
    my ($self, $openresty, $http_meth, $bits) = @_;
    my $level = @$bits - 1;
    my $name = $self->level2name($level);
    if (!defined $name) {
        die "Unknown URL level: $level\n";
    }
    my $meth = $http_meth . '_' . $name;
    if (!$self->can($meth)) {
        $name =~ s/_/ /g;
        die "HTTP $http_meth method not supported for $name.\n";
    }
    $self->$meth($openresty, $bits);
}

sub register {
    my $class = shift;
    for my $cat (@_) {
        $OpenResty::Dispatcher::Handlers{$cat} = $class;
    }
}

sub requires_acl { 1; }

1;

