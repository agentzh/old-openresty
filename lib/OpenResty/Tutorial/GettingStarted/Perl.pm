=encoding utf8

=head1 NAME

OpenResty::Tutorial::GettingStarted::Perl - Zero to OpenResty for Perl
programmers

=head1 DESCRIPTION

This tutorial should give you everything you need to start with an
OpenResty account using Perl.

=head1 Prerequisites

=over

=item An OpenResty account

You should already have an account on an OpenResty server. You can
either set up an OpenResty server on your own machine or just request an
account on our Yahoo! China's production server by sending an email to
C<agentzh@yahoo.cn>. If you're running your own instance of the OpenResty
server, you can use the following command to create an account (named
C<foo>) for yourself:

    $ bin/openresty adduser foo

You'll be prompted to enter a password for the C<Admin> role of your
C<foo> account.

Throughout this tutorial, we'll assume you own an account named C<foo>
whose C<Admin> role's password is C<hello1234>.

=item L<WWW::OpenResty::Simple>

Because OpenResty's API is totally RESTful, that is, it's totally
HTTP based. So it's completely okay to directly use a general HTTP
client libary like L<LWP::UserAgent>. But to make things even easier,
we'll stick with a CPAN module, L<WWW::OpenResty::Simple>, throughout the
tutorial. In case you don't know, installing the L<WWW::OpenResty::Simple>
module is as simple as

    $ sudo cpan WWW::OpenResty::Simple

Commands will differ slightly if you're on Win32:

    C:\>cpan WWW::OpenResty::Simple

=back

Note that if you use an account on others' OpenResty servers (like ours),
you need I<not> install the hairy L<OpenResty> module on CPAN.

=head1 Just Mudding Around

=head1 Importing huge amount of data

=head1 Sharing your data with others

=head1 Keeping a data backup at your localhost

=head1 Where to go from here

=head1 AUTHOR

Agent Zhang (agentzh) C<agentzh@yahoo.cn>

Copyright (c) 2007 by Yahoo! China EEEE Works, Alibaba Inc.

