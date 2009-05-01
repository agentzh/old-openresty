#line 1
package Module::Install::Metadata;

use strict 'vars';
use Module::Install::Base;

use vars qw{$VERSION @ISA $ISCORE};
BEGIN {
	$VERSION = '0.85';
	@ISA     = qw{Module::Install::Base};
	$ISCORE  = 1;
}

my @boolean_keys = qw{
	sign
	mymeta
};

my @scalar_keys = qw{
	name
	module_name
	abstract
	author
	version
	distribution_type
	tests
	installdirs
};

my @tuple_keys = qw{
	configure_requires
	build_requires
	requires
	recommends
	bundles
	resources
};

my @resource_keys = qw{
	homepage
	bugtracker
	repository
};

my @array_keys = qw{
	keywords
};

sub Meta              { shift          }
sub Meta_BooleanKeys  { @boolean_keys  }
sub Meta_ScalarKeys   { @scalar_keys   }
sub Meta_TupleKeys    { @tuple_keys    }
sub Meta_ResourceKeys { @resource_keys }
sub Meta_ArrayKeys    { @array_keys    }

foreach my $key ( @boolean_keys ) {
	*$key = sub {
		my $self = shift;
		if ( defined wantarray and not @_ ) {
			return $self->{values}->{$key};
		}
		$self->{values}->{$key} = ( @_ ? $_[0] : 1 );
		return $self;
	};
}

foreach my $key ( @scalar_keys ) {
	*$key = sub {
		my $self = shift;
		return $self->{values}->{$key} if defined wantarray and !@_;
		$self->{values}->{$key} = shift;
		return $self;
	};
}

foreach my $key ( @array_keys ) {
	*$key = sub {
		my $self = shift;
		return $self->{values}->{$key} if defined wantarray and !@_;
		$self->{values}->{$key} ||= [];
		push @{$self->{values}->{$key}}, @_;
		return $self;
	};
}

foreach my $key ( @resource_keys ) {
	*$key = sub {
		my $self = shift;
		unless ( @_ ) {
			return () unless $self->{values}->{resources};
			return map  { $_->[1] }
			       grep { $_->[0] eq $key }
			       @{ $self->{values}->{resources} };
		}
		return $self->{values}->{resources}->{$key} unless @_;
		my $uri = shift or die(
			"Did not provide a value to $key()"
		);
		$self->resources( $key => $uri );
		return 1;
	};
}

foreach my $key ( grep { $_ ne "resources" } @tuple_keys) {
	*$key = sub {
		my $self = shift;
		return $self->{values}->{$key} unless @_;
		my @added;
		while ( @_ ) {
			my $module  = shift or last;
			my $version = shift || 0;
			push @added, [ $module, $version ];
		}
		push @{ $self->{values}->{$key} }, @added;
		return map {@$_} @added;
	};
}

# Resource handling
my %lc_resource = map { $_ => 1 } qw{
	homepage
	license
	bugtracker
	repository
};

sub resources {
	my $self = shift;
	while ( @_ ) {
		my $name  = shift or last;
		my $value = shift or next;
		if ( $name eq lc $name and ! $lc_resource{$name} ) {
			die("Unsupported reserved lowercase resource '$name'");
		}
		$self->{values}->{resources} ||= [];
		push @{ $self->{values}->{resources} }, [ $name, $value ];
	}
	$self->{values}->{resources};
}

# Aliases for build_requires that will have alternative
# meanings in some future version of META.yml.
sub test_requires     { shift->build_requires(@_) }
sub install_requires  { shift->build_requires(@_) }

# Aliases for installdirs options
sub install_as_core   { $_[0]->installdirs('perl')   }
sub install_as_cpan   { $_[0]->installdirs('site')   }
sub install_as_site   { $_[0]->installdirs('site')   }
sub install_as_vendor { $_[0]->installdirs('vendor') }

sub dynamic_config {
	my $self = shift;
	unless ( @_ ) {
		warn "You MUST provide an explicit true/false value to dynamic_config\n";
		return $self;
	}
	$self->{values}->{dynamic_config} = $_[0] ? 1 : 0;
	return 1;
}

sub perl_version {
	my $self = shift;
	return $self->{values}->{perl_version} unless @_;
	my $version = shift or die(
		"Did not provide a value to perl_version()"
	);

	# Normalize the version
	$version = $self->_perl_version($version);

	# We don't support the reall old versions
	unless ( $version >= 5.005 ) {
		die "Module::Install only supports 5.005 or newer (use ExtUtils::MakeMaker)\n";
	}

	$self->{values}->{perl_version} = $version;
}

#Stolen from M::B
my %license_urls = (
    perl         => 'http://dev.perl.org/licenses/',
    apache       => 'http://apache.org/licenses/LICENSE-2.0',
    artistic     => 'http://opensource.org/licenses/artistic-license.php',
    artistic_2   => 'http://opensource.org/licenses/artistic-license-2.0.php',
    lgpl         => 'http://opensource.org/licenses/lgpl-license.php',
    lgpl2        => 'http://opensource.org/licenses/lgpl-2.1.php',
    lgpl3        => 'http://opensource.org/licenses/lgpl-3.0.html',
    bsd          => 'http://opensource.org/licenses/bsd-license.php',
    gpl          => 'http://opensource.org/licenses/gpl-license.php',
    gpl2         => 'http://opensource.org/licenses/gpl-2.0.php',
    gpl3         => 'http://opensource.org/licenses/gpl-3.0.html',
    mit          => 'http://opensource.org/licenses/mit-license.php',
    mozilla      => 'http://opensource.org/licenses/mozilla1.1.php',
    open_source  => undef,
    unrestricted => undef,
    restrictive  => undef,
    unknown      => undef,
);

sub license {
	my $self = shift;
	return $self->{values}->{license} unless @_;
	my $license = shift or die(
		'Did not provide a value to license()'
	);
	$self->{values}->{license} = $license;

	# Automatically fill in license URLs
	if ( $license_urls{$license} ) {
		$self->resources( license => $license_urls{$license} );
	}

	return 1;
}

sub all_from {
	my ( $self, $file ) = @_;

	unless ( defined($file) ) {
		my $name = $self->name or die(
			"all_from called with no args without setting name() first"
		);
		$file = join('/', 'lib', split(/-/, $name)) . '.pm';
		$file =~ s{.*/}{} unless -e $file;
		unless ( -e $file ) {
			die("all_from cannot find $file from $name");
		}
	}
	unless ( -f $file ) {
		die("The path '$file' does not exist, or is not a file");
	}

	# Some methods pull from POD instead of code.
	# If there is a matching .pod, use that instead
	my $pod = $file;
	$pod =~ s/\.pm$/.pod/i;
	$pod = $file unless -e $pod;

	# Pull the different values
	$self->name_from($file)         unless $self->name;
	$self->version_from($file)      unless $self->version;
	$self->perl_version_from($file) unless $self->perl_version;
	$self->author_from($pod)        unless $self->author;
	$self->license_from($pod)       unless $self->license;
	$self->abstract_from($pod)      unless $self->abstract;

	return 1;
}

sub provides {
	my $self     = shift;
	my $provides = ( $self->{values}->{provides} ||= {} );
	%$provides = (%$provides, @_) if @_;
	return $provides;
}

sub auto_provides {
	my $self = shift;
	return $self unless $self->is_admin;
	unless (-e 'MANIFEST') {
		warn "Cannot deduce auto_provides without a MANIFEST, skipping\n";
		return $self;
	}
	# Avoid spurious warnings as we are not checking manifest here.
	local $SIG{__WARN__} = sub {1};
	require ExtUtils::Manifest;
	local *ExtUtils::Manifest::manicheck = sub { return };

	require Module::Build;
	my $build = Module::Build->new(
		dist_name    => $self->name,
		dist_version => $self->version,
		license      => $self->license,
	);
	$self->provides( %{ $build->find_dist_packages || {} } );
}

sub feature {
	my $self     = shift;
	my $name     = shift;
	my $features = ( $self->{values}->{features} ||= [] );
	my $mods;

	if ( @_ == 1 and ref( $_[0] ) ) {
		# The user used ->feature like ->features by passing in the second
		# argument as a reference.  Accomodate for that.
		$mods = $_[0];
	} else {
		$mods = \@_;
	}

	my $count = 0;
	push @$features, (
		$name => [
			map {
				ref($_) ? ( ref($_) eq 'HASH' ) ? %$_ : @$_ : $_
			} @$mods
		]
	);

	return @$features;
}

sub features {
	my $self = shift;
	while ( my ( $name, $mods ) = splice( @_, 0, 2 ) ) {
		$self->feature( $name, @$mods );
	}
	return $self->{values}->{features}
		? @{ $self->{values}->{features} }
		: ();
}

sub no_index {
	my $self = shift;
	my $type = shift;
	push @{ $self->{values}->{no_index}->{$type} }, @_ if $type;
	return $self->{values}->{no_index};
}

sub read {
	my $self = shift;
	$self->include_deps( 'YAML::Tiny', 0 );

	require YAML::Tiny;
	my $data = YAML::Tiny::LoadFile('META.yml');

	# Call methods explicitly in case user has already set some values.
	while ( my ( $key, $value ) = each %$data ) {
		next unless $self->can($key);
		if ( ref $value eq 'HASH' ) {
			while ( my ( $module, $version ) = each %$value ) {
				$self->can($key)->($self, $module => $version );
			}
		} else {
			$self->can($key)->($self, $value);
		}
	}
	return $self;
}

sub write {
	my $self = shift;
	return $self unless $self->is_admin;
	$self->admin->write_meta;
	return $self;
}

sub version_from {
	require ExtUtils::MM_Unix;
	my ( $self, $file ) = @_;
	$self->version( ExtUtils::MM_Unix->parse_version($file) );
}

sub abstract_from {
	require ExtUtils::MM_Unix;
	my ( $self, $file ) = @_;
	$self->abstract(
		bless(
			{ DISTNAME => $self->name },
			'ExtUtils::MM_Unix'
		)->parse_abstract($file)
	 );
}

# Add both distribution and module name
sub name_from {
	my ($self, $file) = @_;
	if (
		Module::Install::_read($file) =~ m/
		^ \s*
		package \s*
		([\w:]+)
		\s* ;
		/ixms
	) {
		my ($name, $module_name) = ($1, $1);
		$name =~ s{::}{-}g;
		$self->name($name);
		unless ( $self->module_name ) {
			$self->module_name($module_name);
		}
	} else {
		die("Cannot determine name from $file\n");
	}
}

sub perl_version_from {
	my $self = shift;
	if (
		Module::Install::_read($_[0]) =~ m/
		^
		(?:use|require) \s*
		v?
		([\d_\.]+)
		\s* ;
		/ixms
	) {
		my $perl_version = $1;
		$perl_version =~ s{_}{}g;
		$self->perl_version($perl_version);
	} else {
		warn "Cannot determine perl version info from $_[0]\n";
		return;
	}
}

sub author_from {
	my $self    = shift;
	my $content = Module::Install::_read($_[0]);
	if ($content =~ m/
		=head \d \s+ (?:authors?)\b \s*
		([^\n]*)
		|
		=head \d \s+ (?:licen[cs]e|licensing|copyright|legal)\b \s*
		.*? copyright .*? \d\d\d[\d.]+ \s* (?:\bby\b)? \s*
		([^\n]*)
	/ixms) {
		my $author = $1 || $2;
		$author =~ s{E<lt>}{<}g;
		$author =~ s{E<gt>}{>}g;
		$self->author($author);
	} else {
		warn "Cannot determine author info from $_[0]\n";
	}
}

sub license_from {
	my $self = shift;
	if (
		Module::Install::_read($_[0]) =~ m/
		(
			=head \d \s+
			(?:licen[cs]e|licensing|copyright|legal)\b
			.*?
		)
		(=head\\d.*|=cut.*|)
		\z
	/ixms ) {
		my $license_text = $1;
		my @phrases      = (
			'under the same (?:terms|license) as perl itself' => 'perl',        1,
			'GNU general public license'                      => 'gpl',         1,
			'GNU public license'                              => 'gpl',         1,
			'GNU lesser general public license'               => 'lgpl',        1,
			'GNU lesser public license'                       => 'lgpl',        1,
			'GNU library general public license'              => 'lgpl',        1,
			'GNU library public license'                      => 'lgpl',        1,
			'BSD license'                                     => 'bsd',         1,
			'Artistic license'                                => 'artistic',    1,
			'GPL'                                             => 'gpl',         1,
			'LGPL'                                            => 'lgpl',        1,
			'BSD'                                             => 'bsd',         1,
			'Artistic'                                        => 'artistic',    1,
			'MIT'                                             => 'mit',         1,
			'proprietary'                                     => 'proprietary', 0,
		);
		while ( my ($pattern, $license, $osi) = splice(@phrases, 0, 3) ) {
			$pattern =~ s{\s+}{\\s+}g;
			if ( $license_text =~ /\b$pattern\b/i ) {
				$self->license($license);
				return 1;
			}
		}
	}

	warn "Cannot determine license info from $_[0]\n";
	return 'unknown';
}

sub _extract_bugtracker {
	my @links   = $_[0] =~ m#L<(\Qhttp://rt.cpan.org/\E[^>]+)>#g;
	my %links;
	@links{@links}=();
	@links=keys %links;
	return @links;
}

sub bugtracker_from {
	my $self    = shift;
	my $content = Module::Install::_read($_[0]);
	my @links   = _extract_bugtracker($content);
	unless ( @links ) {
		warn "Cannot determine bugtracker info from $_[0]\n";
		return 0;
	}
	if ( @links > 1 ) {
		warn "Found more than on rt.cpan.org link in $_[0]\n";
		return 0;
	}

	# Set the bugtracker
	bugtracker( $links[0] );
	return 1;
}

sub requires_from {
	my $self     = shift;
	my $content  = Module::Install::_readperl($_[0]);
	my @requires = $content =~ m/^use\s+([^\W\d]\w*(?:::\w+)*)\s+([\d\.]+)/mg;
	while ( @requires ) {
		my $module  = shift @requires;
		my $version = shift @requires;
		$self->requires( $module => $version );
	}
}

# Convert triple-part versions (eg, 5.6.1 or 5.8.9) to
# numbers (eg, 5.006001 or 5.008009).
# Also, convert double-part versions (eg, 5.8)
sub _perl_version {
	my $v = $_[-1];
	$v =~ s/^([1-9])\.([1-9]\d?\d?)$/sprintf("%d.%03d",$1,$2)/e;	
	$v =~ s/^([1-9])\.([1-9]\d?\d?)\.(0|[1-9]\d?\d?)$/sprintf("%d.%03d%03d",$1,$2,$3 || 0)/e;
	$v =~ s/(\.\d\d\d)000$/$1/;
	$v =~ s/_.+$//;
	if ( ref($v) ) {
		$v = $v + 0; # Numify
	}
	return $v;
}





######################################################################
# MYMETA.yml Support

sub WriteMyMeta {
	die "WriteMyMeta has been deprecated";
}

sub write_mymeta {
	my $self = shift;
	
	# If there's no existing META.yml there is nothing we can do
	return unless -f 'META.yml';

	# We need YAML::Tiny to write the MYMETA.yml file
	unless ( eval { require YAML::Tiny; 1; } ) {
		return 1;
	}

	# Merge the perl version into the dependencies
	my $val  = $self->Meta->{values};
	my $perl = delete $val->{perl_version};
	if ( $perl ) {
		$val->{requires} ||= [];
		my $requires = $val->{requires};

		# Canonize to three-dot version after Perl 5.6
		if ( $perl >= 5.006 ) {
			$perl =~ s{^(\d+)\.(\d\d\d)(\d*)}{join('.', $1, int($2||0), int($3||0))}e
		}
		unshift @$requires, [ perl => $perl ];
	}

	# Load the advisory META.yml file
	my @yaml = YAML::Tiny::LoadFile('META.yml');
	my $meta = $yaml[0];

	# Overwrite the non-configure dependency hashs
	delete $meta->{requires};
	delete $meta->{build_requires};
	delete $meta->{recommends};
	if ( exists $val->{requires} ) {
		$meta->{requires} = { map { @$_ } @{ $val->{requires} } };
	}
	if ( exists $val->{build_requires} ) {
		$meta->{build_requires} = { map { @$_ } @{ $val->{build_requires} } };
	}

	# Save as the MYMETA.yml file
	print "Writing MYMETA.yml\n";
	YAML::Tiny::DumpFile('MYMETA.yml', $meta);	
}

1;
