use t::OpenAPI;

plan tests => 3 * blocks;

run_tests;

__DATA__

=== TEST 1: 2008-02
--- request
GET /=/view/.Calendar/~/~?year=2008&month=2
--- response
[
    {"sun":null,"mon":null,"tue":null,"wed":null,"thu":null,"fri":1,"sat":2},
    {"sun":3,"mon":4,"tue":5,"wed":6,"thu":7,"fri":8,"sat":9},
    {"sun":10,"mon":11,"tue":12,"wed":13,"thu":14,"fri":15,"sat":16},
    {"sun":17,"mon":18,"tue":19,"wed":20,"thu":21,"fri":22,"sat":23},
    {"sun":24,"mon":25,"tue":26,"wed":27,"thu":28,"fri":29,"sat":null}
]


