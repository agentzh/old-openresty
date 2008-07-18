all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	jemplate --compile template/elem/ > out/jemplates.js
	jemplate --runtime > out/Jemplate.js
	tpage --include_path=template template/index.tt > out/index.html
	tpage --define cat=model template/js/handlers.tt > out/model.js
	tpage --define cat=view template/js/handlers.tt > out/view.js
	tpage --define cat=role template/js/handlers.tt > out/role.js
	tpage --define cat=feed template/js/handlers.tt > out/feed.js
	tpage template/js/dispatcher.tt > out/dispatcher.js
	cp html/login.html out/
	cp ../Blog/image/loading.gif out/
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	tar cf site-binary.tar out
	gzip -q --best site-binary.tar
	mv site-binary.tar.gz out/

upload: all
	scp -l 10000 -r `pwd`/out agentz@openresty.org:~/admin

