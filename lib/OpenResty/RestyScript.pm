package OpenResty::RestyScript;

use strict;
use warnings;

use FindBin;
use Carp qw(croak);
use IPC::Run3;

my $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";

sub new {
    my ($class, $type, $src) = @_;
    if (!-f $ExePath) {
        croak "Restyscript compiler cannot found at $ExePath";
    }
    if (!-x $ExePath) {
        croak "Restyscript compiler is not executable: $ExePath";
    }
    return bless {
        _src => $src,
        _type => $type,
    }, $class;
}

sub rename {
    my ($self, $var, $newvar) = @_;
    my ($stdout, $stderr);
    my $type = $self->{_type};
    my $stdin = $self->{_src};
    run3 [$ExePath, $type, 'rename', $var, $newvar], \$stdin, \$stdout, \$stderr;
    if ($? != 0) {
        croak ($stderr || "Failed to call \"$ExePath $type rename $var $newvar\": returned status code " . ($? >> 8);
    }
    $stdout;
}

sub compile {
    my ($self) = @_;
    my ($stdout, $stderr);
    my $type = $self->{_type};
    my $stdin = $self->{_src};
    run3 [$ExePath, $type, 'frags', 'stats'], \$stdin, \$stdout, \$stderr;
    if ($? != 0) {
        croak ($stderr || "Failed to call \"$ExePath $type frags stats\": returned status code " . ($? >> 8);
    }
    $stdout;
}

1;

