# vi:filetype=

my $reason;
BEGIN {
	eval {
		require OpenResty::Filter::QP;
	};
	if ($@) {
		$reason = 'Skipped because QP Filter is for internal use only';
	}
}

use t::OpenResty $reason ? (skip_all => $reason) : ();

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Clear the environment
--- request
DELETE /=/model?_user=$TestAccount&_password=$TestPass&_use_cookie=1
--- response
{"success":1}



=== TEST 2: Create a model
--- request
POST /=/model/Foo
{
    "description":"foo",
    "columns":
        [ {"name":"text", "type":"text", "label":"Text"} ]
}
--- response
{"success":1}



=== TEST 3: Post a sexist's content
--- request
POST /=/model/Foo/~/~
{ "text": "oh, what a fuck!" }
--- response
{"success":0,"error":"QP filter: Sexist not welcomed."}



=== TEST 4: logout
--- request
GET /=/logout
--- response
{"success":1}

