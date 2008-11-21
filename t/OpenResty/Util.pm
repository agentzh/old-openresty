package t::OpenResty::Util;

# this file contains util that can't be in t::openresty, because
# spiffy is polluting the args passed in for some unknown reasons

sub ensure_test_user {
    my ($user, $password) = @_;
    if ($OpenResty::Config{'backend.type'} eq 'PgMocked') {
        return;
    }
    local $SIG{__WARN__} = sub { }
        unless $ENV{TEST_VERBOSE};
    unless ($ENV{OPENRESTY_TEST_SERVER}) {
        my $backend = $OpenResty::Backend;
        if ( $backend->has_user($user) ) {
            $backend->drop_user($user);
        }
        $backend->add_user($user, $password);
        $backend->has_user($user)
            or Test::More::BAIL_OUT('Can not create test user');
    }
}

1;
