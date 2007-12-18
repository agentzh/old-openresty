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
"create table _books (id serial primary key, body text, num integer default 0);
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
    {"body":"Larry Wall","num":"0","id":"1"},
    {"body":"Audrey Tang","num":"0","id":"2"}
]



=== TEST 6: CREATE FUNCTION
--- request
POST /=/admin/do
"CREATE OR REPLACE FUNCTION add_child() returns trigger as $$ 
	begin 
		if NEW.id <> 0 then 
			update _books set num=num+1 where id=1; 
		END IF;
		return NEW; 
	end; 
$$ language plpgsql;"
--- response
{"success":1}



=== TEST 7: create tirgger
--- request
POST /=/admin/do
"CREATE TRIGGER add_child_t BEFORE INSERT ON _books FOR EACH ROW EXECUTE PROCEDURE add_child();"
--- response
{"success":1}



=== TEST 8: Insert some records
--- request
POST /=/admin/do
"insert into _books (body) values ('Larry Wall');
insert into _books (body) values ('Audrey Tang');
insert into _cats (name) values ('mimi');"
--- response
{"success":1}



=== TEST 9: Select data
--- request
POST /=/admin/select
"select * from _books where id=1"
--- response
[{"body":"Larry Wall","num":"2","id":"1"}]




=== TEST 10: drop tables
--- request
POST /=/admin/do
"drop table if exists _books;
drop table if exists _cats;"
--- response
{"success":1}


