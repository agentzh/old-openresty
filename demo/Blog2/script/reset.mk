password=
server=
user=

export:
	-mkdir backup
	-cp *.json backup
	../../bin/export-model.pl --user $(user) --model Comment --server $(server) --out Comment.json --password $(password)
	../../bin/export-model.pl --user $(user) --model Post --server $(server) --out Post.json --password $(password)

import:
	script/init.pl -u $(user) -p $(password) -s $(server)
	../../bin/import-model.pl --reset --step 1 --user $(user) --password $(password) --model Post --server $(server) Post.json
	../../bin/import-model.pl --reset --user $(user) --password $(password) --model Comment --server $(server) Comment.json

# create or replace function to_fti(text, text) returns tsvector as $$ select setweight(to_tsvector('chinesecfg', $1), 'A') || to_tsvector('chinesecfg', $2) $$ language sql immutable;
# select title, ts_headline('chinesecfg', content, q) as headline from "Post", to_tsquery('chinesecfg', 'OpenResty|Google') as q where to_fti(title, content) @@ q order by ts_rank(to_fti(title, content), q) desc;
#

