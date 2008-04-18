password=
server=

export:
	-mkdir backup
	-cp *.json backup
	../../bin/export-model.pl --user eeee --password $(password) --model Comment --server $(server) --out Comment.json
	../../bin/export-model.pl --user eeee --password $(password) --model Post --server $(server) --out Post.json

import:
	script/init.pl -u eeee -p $(password) -s $(server)
	../../bin/import-model.pl --reset --no-id --user eeee --password $(password) --model Post --server $(server) Post.json
	../../bin/import-model.pl --reset --no-id --user eeee --password $(password) --model Comment --server $(server) Comment.json

