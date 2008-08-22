# vi:filetype=
use Test::Base;

use JavaScript::SpiderMonkey;
use JSON::XS;
#use Test::LongString;
#use Data::Structure;
use utf8;
use Encode;

my $json_xs = JSON::XS->new->allow_nonref;

plan tests => blocks() * 1;

my $jsfile = 'js/pod2html.js';

my $monkey = new JavaScript::SpiderMonkey;
$monkey->init();

open my $in, $jsfile or
    die "Failed to open JS file $jsfile: $!\n";
my $js = do { local $/; <$in> };
close $in;

$monkey->eval($js) or
    die "Failed to load $jsfile: $@";

my $res;
$monkey->function_set('get', sub { $res = shift });

run {
    my $block = shift;
    my $name = $block->name;
    my $pod = $block->pod or die "No -- pod specified for $name";
    my $json = $json_xs->encode($pod);
    $monkey->eval("get(pod2html($json))") or
        die "Error occured when calling the pod2html function: $@";
    $res = Encode::decode('utf8', $res);
    is "$res\n", $block->html, "$name - HTML output okay";
};

$monkey->destroy();

__DATA__

=== TEST 1: =image
--- pod
=image gate.jpg
--- html
<p><img src="gate.jpg"/></p>



=== TEST 2: ignore =pod, =cut, =encoding
--- pod
=pod

=cut

=encoding utf8

hi
--- html
<p>hi</p>



=== TEST 3: L<url> works
--- pod
L<http://agentzh.org/#elem/home/1>
--- html
<p><a href="http://agentzh.org/#elem/home/1">http://agentzh.org/#elem/home/1</a></p>



=== TEST 4: indented paragraphs work
--- pod
 hello
   world
--- html
<pre> hello
   world</pre>



=== TEST 5: head1 & indented text
--- pod
=head1 A B C

 hello
  world
--- html
<h1>A B C</h1>
<pre> hello
  world</pre>



=== TEST 6: head3 & normal paragraphs
--- pod
=head3  hi

hello, world
Ahah!

dog is here.
--- html
<h3>hi</h3>
<p>hello, world
Ahah!</p>
<p>dog is here.</p>



=== TEST 7: C<...> works
--- pod
C<hello>, world
--- html
<p><code>hello</code>, world</p>



=== TEST 8: F<...> works
--- pod
F</usr/bin/perl>
--- html
<p><em>/usr/bin/perl</em></p>



=== TEST 9: I<...> works
--- pod
She loves I<me>!
--- html
<p>She loves <i>me</i>!</p>



=== TEST 10: B<...> works
--- pod
She loves B<me>!
--- html
<p>She loves <b>me</b>!</p>



=== TEST 11: over & =item *
--- pod
=over 4

=item *

Hello, world

*grin*

=back
--- html
<ul>
<li>
Hello, world
<p>*grin*</p>
</li></ul>



=== TEST 12: pre as item title
--- pod
=over

=item *

 abc

hello

=back
--- html
<ul>
<li>
<pre> abc</pre>
<p>hello</p>
</li></ul>



=== TEST 12: over & 2 =item *
--- pod
=over

=item *

ABC

=item *

*grin*

=back
--- html
<ul>
<li>
ABC
</li><li>
*grin*
</li></ul>


=== TEST 13: nested <ul>
--- pod
=over


=item *


ABC


=over


=item *


QQQ


=back


=back
--- html
<ul>
<li>
ABC
<ul>
<li>
QQQ
</li></ul>
</li></ul>



=== TEST 14: item 1. item 2. ...
--- pod
=over


=item 1.


ABC


=item 2.


QQQ


hello


=back
--- html
<ol>
<li>
ABC
</li><li>
QQQ
<p>hello</p>
</li></ol>



=== TEST 15: nested <ul> and <ol>
--- pod

=over


=item *


ABC


=over


=item 1.


QQQ


=back


=back
--- html
<ul>
<li>
ABC
<ol>
<li>
QQQ
</li></ol>
</li></ul>



=== TEST 16: =item XXX
--- pod
=over


=item ABC


English words


Oh oh!


=item hello, world


=back
--- html
<dl>
<dt>ABC</dt><dd>
<p>English words</p>
<p>Oh oh!</p>
</dd><dt>hello, world</dt><dd>
</dd></dl>



=== TEST 17: quotes
--- pod
C<< 2>3 >> F<F> I<I> B<B>
--- html
<p><code> 2&gt;3 </code> <em>F</em> <i>I</i> <b>B</b></p>



=== TEST 18: misc
--- pod
=head1 Hello


=over


=item *


hi


=back


  3 > 4
  532aa


L<http://blog.agentzh|agentzh>
--- html
<h1>Hello</h1>
<ul>
<li>
hi
</li></ul>
<pre>  3 &gt; 4
  532aa</pre>
<p><a href="http://blog.agentzh">agentzh</a></p>



=== TEST 19: head4 works
--- pod
=head4 你好么 ABC
--- html
<h4>你好么 ABC</h4>



=== TEST 20: misc2
--- pod
=over


=item 1.


cat is not a dog.
and he is always here.

really?


=item 2.


  hello, world
  haha


=back
--- html
<ol>
<li>
cat is not a dog.
and he is always here.
<p>really?</p>
</li><li>
<pre>  hello, world
  haha</pre>
</li></ol>

