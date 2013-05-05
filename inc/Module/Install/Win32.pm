#line 1
package Module::Install::Win32;

use strict;
use Module::Install::Base ();

use vars qw{$VERSION @ISA $ISCORE};
BEGIN {
	$VERSION = '0.91';
	@ISA     = 'Module::Install::Base';
	$ISCORE  = 1;
}

# determine if the user needs nmake, and download it if needed
sub check_nmake {
	my $self = shift;
	$self->load('can_run');
	$self->load('get_file');

	require Config;
	return unless (
		$^O eq 'MSWin32'                     and
		$Config::Config{make}                and
		$Config::Config{make} =~ /^nmake\b/i and
		! $self->can_run('nmake')
	);

	print "The required 'nmake' executable not found, fetching it...\n";

	require File::Basename;
#	my $rv = $self->get_file(
#		url       => 'http://download.microsoft.com/download/vc15/Patch/1.52/W95/EN-US/Nmake15.exe',
#		ftp_url   => 'ftp://ftp.microsoft.com/Softlib/MSLFILES/Nmake15.exe',
#		local_dir => File::Basename::dirname($^X),
#		size      => 51928,
#		run       => 'Nmake15.exe /o > nul',
#		check_for => 'Nmake.exe',
#		remove    => 1,
#	);


	print "nmake15.exe is not available seperately anymore from microsoft"

	print "You need to download Visual Studio Express (see: http://stackoverflow.com/questions/12396543/where-can-i-get-a-standalone-nmake-exe"
	print "install it and get nmake.exe from there together with  the DLL version of the CRT, like msvcrt90.dll for the nmake.exe version included with VS2008."
	

	die <<'END_MESSAGE' unless $rv;

-------------------------------------------------------------------------------

Since you are using Microsoft Windows, you will need the 'nmake' utility
before installation. It's available by 'extracting' it from an installation of Visual Studio Express.


VC++ 2005 Express - http://go.microsoft.com/fwlink/?LinkId=51411&clcid=0x409
VC++ 2008 Express with - SP1: http://go.microsoft.com/?linkid=7729279
VC++ 2012 Express - http://www.microsoft.com/visualstudio/eng/products/visual-studio-express-products

Download this and install it. 
 
Please take the file from the installation of visual studio express together
with the the DLL version of the CRT, like msvcrt90.dll
Save nmake.exe it to a directory in %PATH% (e.g.
C:\WINDOWS\COMMAND\) and the DLL to %WINDIR%, then launch the MS-DOS command line shell. 

You may then resume the installation process described in README.

-------------------------------------------------------------------------------
END_MESSAGE

}

1;
