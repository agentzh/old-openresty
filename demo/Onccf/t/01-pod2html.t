use t::TestJS;

// JS code starts from here...

plan(1);

include('js/pod2html.js');
is(pod2html('C<hello>'), '<code>hello</code>', "C<...> works");

