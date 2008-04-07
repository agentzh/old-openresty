all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	jemplate --compile template/elem/ > out/jemplates.js
	jemplate --runtime > out/Jemplate.js
	tpage --include_path=template template/index.tt > out/index.html
	cp html/login.html out/
	cp ../Blog/image/loading.gif out/
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/

