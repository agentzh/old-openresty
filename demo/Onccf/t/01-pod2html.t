# vi:filetype=javascript
use t::TestJS;

// JS code starts from here...

plan(5);

include('js/pod2html.js');

is(pod2html('C<hello>, world'), '<code>hello</code>, world', "C<...> works");
is(pod2html('F</usr/bin/perl>'), '<em>/usr/bin/perl</em>', "F<...> works");
is(pod2html('She loves I<me>!'), 'She loves <i>me</i>!', "I<...> works");
is(pod2html('She loves B<me>!'), 'She loves <b>me</b>!', "B<...> works");

var pod =
    "C<< 2>3 >> F<F> I<I> B<B>\n\n" +
    "=head1 Hello\n\n" +
    "=over\n\n" +
    "=item *\n\n" +
    "hi\n\n" +
    "=back\n\n" +
    "  3 > 4\n" +
    "  532aa\n" +
    "L<http://blog.agentzh|agentzh>";

is_string(
    pod2html(pod),
    "<code> 2&gt;3 </code> <em>F</em> <i>I</i> <b>B</b><h1>Hello</h1><ul><li>hi</li></ul><br/><br/><code>&nbsp; &nbsp; 3 &gt; 4</code><br/>\n<code>&nbsp; &nbsp; 532aa</code><br/>\n<a href=\"http://blog.agentzh\">agentzh</a>",
    'long POD works'
);

