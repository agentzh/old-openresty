package OpenResty::RestyScript;

use strict;
use warnings;

#use Smart::Comments;
use FindBin;
use Carp qw(croak);
use IPC::Run qw(run timeout);
use JSON::XS;

my $json = JSON::XS->new->utf8;

my $ExePath = "$FindBin::Bin/../haskell/bin/restyscript";
my $ExePath2 = "$FindBin::Bin/restyscript";

sub new {
    my ($class, $type, $src) = @_;
    if (!-f $ExePath && !-f $ExePath2) {
        croak "Restyscript compiler cannot found at either $ExePath or $ExePath2";
    }
    if (!-f $ExePath) { $ExePath = $ExePath2 }
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
    run [$ExePath, $type, 'rename', $var, $newvar], \$stdin, \$stdout, \$stderr, timeout(1);
    if (!$stdout) {
        die $stderr || "Failed to call \"$ExePath $type rename $var $newvar\": returned status code " . ($? >> 8) . "\n";
    }

    $stdout;
}

sub compile {
    my ($self) = @_;
    my ($stdout, $stderr);
    my $type = $self->{_type};
    my $stdin = $self->{_src};

    # Note that we can't use the "run ... or die ..." idiom here due to
    # some mysterious failures (status code ) on our
    # production machines (redhat 4)
    run [$ExePath, $type, 'frags', 'stats'], \$stdin, \$stdout, \$stderr, timeout(1);
    #warn "STDOUT: $stdout\n";
    #warn "STDERR: $stderr\n";
    if (!$stdout) {
        die $stderr || "Failed to call \"$ExePath $type frags stats\" returned status code " . ($? >> 8) . "\n";
    }

    ### $stdout
    my @ln = split /\n/, $stdout;
    return ($json->decode($ln[0]), $json->decode($ln[1]))
}

1;
__END__

=head1 NAME

OpenResty::RestyScript - Perl wrapper for the restyscript compiler via IPC

=head1 NAME

The restyscript compiler is written in Haskell and located at haskell/bin/restyscript. This is a Perl wrapper for interact with it via L<IPC::Run3>.

=head1 METHODS

=over

=item C<< $obj = OpenResty::RestyScript->new($type, $src) >>

Create a new OpenResty::RestyScript instance with the C<$type> parameter indicating "view" or "action" and the C<$src> parameter indicating the RestyScript source code.

=item C<< $new_src = $obj->rename($old_var_name, $new_var_name) >>

Renames the variable specified by C<$old_var_name> with the new name specified by $C<new_var_name>, and returns the new source.
R

=item C<< ($frags, $stats) = $obj->compile() >>

=back

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2007, 2008 by Yahoo! China EEEE Works, Alibaba Inc.

This module is free software; you can redistribute it and/or modify it under the Artistic License 2.0. A copy of this license can be obtained from

http://opensource.org/licenses/artistic-license-2.0.php

