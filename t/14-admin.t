use t::OpenAPI;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 1: Delete existing models
--- request
DELETE /=/model.js
--- response
{"success":1}



=== TEST 2: drop tables
--- request
POST /=/admin/do
"drop table if exists _books;
drop table if exists _cats;"
--- response
{"success":1}



=== TEST 3: Create a DB table
--- request
POST /=/admin/do
"create table _books (id serial primary key, body text);
create table _cats (id serial primary key, name text);"
--- response
{"success":1}



=== TEST 4: Insert some records
--- request
POST /=/admin/do
"insert into _books (body) values ('Larry Wall');
insert into _books (body) values ('Audrey Tang');
insert into _cats (name) values ('mimi');"
--- response
{"success":1}



=== TEST 5: Select data
--- request
POST /=/admin/select
"select * from _books"
--- response
[
    {"body":"Larry Wall","id":"1"},
    {"body":"Audrey Tang","id":"2"}
]



=== TEST 6: drop tables
--- request
POST /=/admin/do
"drop table if exists _books;
drop table if exists _cats;"
--- response
{"success":1}


