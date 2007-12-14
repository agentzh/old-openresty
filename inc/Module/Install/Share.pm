#line 1
package Module::Install::Share;

use strict;
use Module::Install::Base;

use vars qw{$VERSION $ISCORE @ISA};
BEGIN {
	$VERSION = '0.67';
	$ISCORE  = 1;
	@ISA     = qw{Module::Install::Base};
}

sub install_share {
	my ($self, $dir) = @_;

	if ( ! defined $dir ) {
		die "Cannot find the 'share' directory" unless -d 'share';
		$dir = 'share';
	}

	$self->postamble(<<"END_MAKEFILE");
config ::
\t\$(NOECHO) \$(MOD_INSTALL) \\
\t\t"$dir" \$(INST_AUTODIR)

END_MAKEFILE

	# The above appears to behave incorrectly when used with old versions
	# of ExtUtils::Install (known-bad on RHEL 3, with 5.8.0)
	# So when we need to install a share directory, make sure we add a
	# dependency on a moderately new version of ExtUtils::MakeMaker.
	$self->build_requires( 'ExtUtils::MakeMaker' => '6.11' );
}

1;

__END__

#line 98
