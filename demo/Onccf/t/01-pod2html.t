# vi:filetype=javascript
use t::TestJS;

// JS code starts from here...

plan(19);

include('js/pod2html.js');

is(pod2html('=image gate.jpg\n\n'), '<p><img src="gate.jpg"/></p>', 'image');
is(pod2html('=pod\n\n=cut\n\n=encoding utf8\n\nhi'), '<p>hi</p>', 'directives ignored');
is(pod2html('L<http://agentzh.org/#elem/home/1>'),
    '<p><a href="http://agentzh.org/#elem/home/1">http://agentzh.org/#elem/home/1</a></p>', 'L<url> works');
is(pod2html(' hello\n  world'), '<pre> hello\n  world</pre>', 'pre');
is_string(pod2html('=head1 A B C\n\n hello\n  world'),
    '<h1>A B C</h1>\n<pre> hello\n  world</pre>', 'head1 & pre');
is_string(pod2html('=head3  hi\n\nhello, world\nAhah!\n\ndog is here.'),
    '<h3>hi</h3>\n<p>hello, world\nAhah!</p>\n<p>dog is here.</p>',
    'head3 & paragrahs');
is(pod2html('C<hello>, world'), '<p><code>hello</code>, world</p>', "C<...> works");
is(pod2html('F</usr/bin/perl>'), '<p><em>/usr/bin/perl</em></p>', "F<...> works");
is(pod2html('She loves I<me>!'), '<p>She loves <i>me</i>!</p>', "I<...> works");
is(pod2html('She loves B<me>!'), '<p>She loves <b>me</b>!</p>', "B<...> works");
is_string(pod2html('=over 4\n\n=item *\n\nHello, world\n\n*grin*\n\n=back'),
    '<ul>\n' +
        '<li>Hello, world</li>\n' +
        '<p>*grin*</p>\n' +
    '</ul>',
    'over & =item *'
);
is_string(pod2html('=over\n\n=item *\n\nABC\n\n=item *\n\n*grin*\n\n=back'),
    '<ul>\n' +
        '<li>ABC</li>\n' +
        '<li>*grin*</li>\n' +
    '</ul>',
    'over & 2 =item *'
);

is(pod2html('=over\n\n' +
    '=item *\n\n' +
    'ABC\n\n' +
    '=over\n\n' +
    '=item *\n\n' +
    'QQQ\n\n' +
    '=back\n\n' +
    '=back'),

    '<ul>\n' +
    '<li>ABC</li>\n' +
    '<ul>\n' +
    '<li>QQQ</li>\n' +
    '</ul>\n' +
    '</ul>',
    'nested <ul>');

is(pod2html('=over\n\n' +
    '=item 1.\n\n' +
    'ABC\n\n' +
    '=item 2.\n\n' +
    'QQQ\n\n' +
    'hello\n\n' +
    '=back'),

    '<ol>\n' +
    '<li>ABC</li>\n' +
    '<li>QQQ</li>\n' +
    '<p>hello</p>\n' +
    '</ol>',
    'ol');

is(pod2html('=over\n\n' +
    '=item *\n\n' +
    'ABC\n\n' +
    '=over\n\n' +
    '=item 1.\n\n' +
    'QQQ\n\n' +
    '=back\n\n' +
    '=back'),

    '<ul>\n' +
    '<li>ABC</li>\n' +
    '<ol>\n' +
    '<li>QQQ</li>\n' +
    '</ol>\n' +
    '</ul>',
    'nested <ul> and <ol>');

is_string(pod2html('=over\n\n' +
    '=item ABC\n\n' +
    'English words\n\n' +
    'Oh oh!\n\n' +
    '=item hello, world\n\n' +
    '=back'),

    '<dl>\n' +
    '<dt>ABC</dt><dd>\n' +
    '<p>English words</p>\n' +
    '<p>Oh oh!</p>\n' +
    '<dt>hello, world</dt><dd>\n' +
    '</dl>',
    'dl test');

//exit();

var pod =
    "C<< 2>3 >> F<F> I<I> B<B>\n\n" +
        "=head1 Hello\n\n" +
        "=over\n\n" +
        "=item *\n\n" +
        "hi\n\n" +
        "=back\n\n" +
        "  3 > 4\n" +
        "  532aa\n\n" +
        "L<http://blog.agentzh|agentzh>";

is_string(
    pod2html(pod),
    "<p><code> 2&gt;3 </code> <em>F</em> <i>I</i> <b>B</b></p>\n" +
        "<h1>Hello</h1>\n" +
        "<ul>\n" +
        "<li>hi</li>\n" +
        "</ul>\n" +
        "<pre>  3 &gt; 4\n" +
        "  532aa</pre>\n" +
        '<p><a href="http://blog.agentzh">agentzh</a></p>',
    'long POD works'
);

is(
    pod2html('=head4 你好么 ABC\n\n'),
    '<h4>你好么 ABC</h4>',
    '=head4 works'
);

is_string(
    pod2html('\n=over\n\n' +
        '=item 1.\n\n' +
        'cat is not a dog.\n' +
        'and he is always here.\n\n' +
        'really?\n\n' +
        '=item 2.\n\n' +
        '  hello, world\n\n' +
        '  haha\n\n' +
        '=back'),
    '<ol>\n' +
    '<li>cat is not a dog.\n' +
    'and he is always here.</li>\n' +
    '<p>really?</p>\n' +
    '<li>  hello, world</li>\n' +
    '<pre>  haha</pre>\n' +
    '</ol>',
    'another long case'
);

