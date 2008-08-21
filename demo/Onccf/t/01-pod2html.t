use t::TestJS;

// JS code starts from here...

plan(4);

include('js/pod2html.js');

is(pod2html('C<hello>, world'), '<code>hello</code>, world', "C<...> works");
is(pod2html('F</usr/bin/perl>'), '<em>/usr/bin/perl</em>', "F<...> works");
is(pod2html('She loves I<me>!'), 'She loves <i>me</i>!', "I<...> works");
is(pod2html('She loves B<me>!'), 'She loves <b>me</b>!', "B<...> works");

