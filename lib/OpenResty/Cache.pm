package OpenResty::Cache;

use strict;
use warnings;
use FindBin;

# This is a hack...

our $NoTrivial = 0;

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    my $params = shift;
    my $type = $OpenResty::Config{'cache.type'} or
        die "No cache.type specified in the config files.\n";
    my $obj;
    my $self = bless {}, $class;
    if ($type eq 'filecache') {
        require Cache::FileCache;
        $obj = Cache::FileCache->new(
            { namespace => 'OpenResty', default_expires_in => 60 * 60 * 24 }
        );
    } elsif ($type eq 'memcached') {
        my $list = $OpenResty::Config{'cache.servers'} or
            die "No cache.servers specified in the config files.\n";
        require Cache::Memcached::libmemcached;
        my @addr = split /\s*,\s*|\s+/, $list;
        if (!@addr) {
            die "No memcached server found: $list.\n";
        }
        $obj = Cache::Memcached::libmemcached->new({
            servers => [@addr],
        });
        #$obj->set(dog => 32);
        #die "Dog value: ", $obj->get('dog');
        #die $obj;
    } else {
        die "Invalid cache.type value: $type\n";
    }
    my $backend_type = $OpenResty::Config{'backend.type'} || '';
    $NoTrivial = $OpenResty::Config{'backend.recording'} ||
        $backend_type eq 'PgMocked';

    if ($obj->can('purge')) {
        $obj->purge();
    }
    $self->{obj} = $obj;
    return $self;
}

# expire_in is in seconds...
sub set {
    my ($self, $key, $val, $expire_in, $trivial) = @_;
    return undef if $trivial && $NoTrivial;
    $self->{obj}->set($key, $val, $expire_in);
}

sub get {
    my ($self, $key, $trivial) = @_;
    return undef if $NoTrivial && $trivial;
    $self->{obj}->get($key);
}

sub remove {
    my $self = shift;
    my $obj = $self->{obj};
    if ($obj->can('remove')) {
        $obj->remove(@_);
    } else {
        $obj->delete(@_);
    }
}

## ------------------------

sub get_has_user {
    my ($self, $user) = @_;
    $self->get("hasuser:$user", 'trivial')
}

sub set_has_user {
    my ($self, $user) = @_;
    $self->set("hasuser:$user", 1, 3600, 'trivial');
}

sub remove_has_user {
    my ($self, $user) = @_;
    $self->remove("hasuser:$user");
}

sub get_last_res {
    my ($self, $id) = @_;
    $self->get("lastres:$id");
}

sub set_last_res {
    my ($self, $id, $val) = @_;
    $self->set("lastres:$id", $val, 5 * 60);
}

sub remove_last_res {
    my ($self, $id) = @_;
    $self->remove("lastres:".$id);
}

sub get_has_model {
    my ($self, $user, $model) = @_;
    $self->get("hasmodel:$user:$model", 'trivial')
}

sub set_has_model {
    my ($self, $user, $model) = @_;
    $self->set("hasmodel:$user:$model", 1, 3600, 'trivial');
}

sub remove_has_model {
    my ($self, $user, $model) = @_;
    $self->remove("hasmodel:$user:$model");
}

sub get_has_view {
    my ($self, $user, $view) = @_;
    #return undef;
    $self->get("hasview:$user:$view", 'trivial')
}

sub set_has_view {
    my ($self, $user, $view) = @_;
    $self->set("hasview:$user:$view", 1, 3600, 'trivial');
}

sub remove_has_view {
    my ($self, $user, $view) = @_;
    $self->remove("hasview:$user:$view");
}

sub get_view_def {
    my ($self, $user, $view) = @_;
    #return undef;
    $self->get("viewdef:$user:$view", 'trivial')
}

sub set_view_def {
    my ($self, $user, $view, $def) = @_;
    $self->set("viewdef:$user:$view", $def, 3600, 'trivial');
}

sub remove_view_def {
    my ($self, $user, $view) = @_;
    $self->remove("viewdef:$user:$view");
}

sub get_has_role {
    my ($self, $user, $role) = @_;
    #return undef;
    $self->get("hasrole:$user:$role", 'trivial')
}

sub set_has_role {
    my ($self, $user, $role, $login_meth) = @_;
    $self->set("hasrole:$user:$role", $login_meth, 3600, 'trivial');
}

sub remove_has_role {
    my ($self, $user, $role) = @_;
    $self->remove("hasrole:$user:$role");
}

sub get_has_action {
    my ($self, $user, $action) = @_;
    #return undef;
    $self->get("hasrole:$user:$action", 'trivial')
}

sub set_has_action {
    my ($self, $user, $action, $compiled) = @_;
    $self->set("hasrole:$user:$action", $compiled, 3600, 'trivial');
}

sub remove_has_action {
    my ($self, $user, $action) = @_;
    $self->remove("hasrole:$user:$action");
}

1;
__END__

=head1 NAME

OpenResty::Cache - Cache for OpenResty

=head1 SYNOPSIS

    use OpenResty::Config;
    use OpenResty::Cache;

    OpenResty::Config->init;
    my $cache = OpenResty::Cache->new;
    $cache->set('key' => 'value'); # use the cache to store (session) data
    $cache->set('key' => 'value', 'trivial'); # pure caching
    print $cache->get('key');  # read the value for the key
    $cache->remove('key');

=head1 DESCRIPTION

This class provides an abstract interface for two caching libraries, L<Cache::FileCache> and L<Cache::Memcached::libmemcached>.

Which underlying cache library to use depends on the C<cache.type> config option in the F<etc/site_openresty.conf> file.

Note that C<filecache> could eat up your hard disk very quickly. (you'll observe the bloating directory F</tmp/FileCache>.) C<filecache> is only suitable for development; for production use, please use C<memcached> instead (by specifying the C<cache.type> and C<cache.servers> options in F<etc/site_openresty.conf>).

=head1 METHODS

=over

=back

=head1 AUTHOR

Yichun Zhang (agentzh) C<< <agentzh@gmail.com> >>.

=head1 SEE ALSO

L<OpenResty>, L<Cache::FileCache>, L<Cache::Memcached::libmemcached>.

