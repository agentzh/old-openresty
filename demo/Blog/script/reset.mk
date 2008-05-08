password=
server=
user=

export:
	-mkdir backup
	-cp *.json backup
	../../bin/export-model.pl --user $(user) --password $(password) --model Comment --server $(server) --out Comment.json
	../../bin/export-model.pl --user $(user) --password $(password) --model Post --server $(server) --out Post.json

import:
	script/init.pl -u $(user) -p $(password) -s $(server)
	../../bin/import-model.pl --reset --step 2 --user $(user) --password $(password) --model Post --server $(server) Post.json
	../../bin/import-model.pl --reset --user $(user) --password $(password) --model Comment --server $(server) Comment.json

