all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	jemplate --compile template/elem/ > out/jemplates.js
	jemplate --runtime > out/Jemplate.js
	tpage --define 'blog_name=Human & Machine' \
	    --define 'blog_desc=The mad house for a Perl guy, agentzh' \
	    --include_path=template template/index.tt > out/index.html
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	cp -r css/themes out/
	cp -r image/*.* out/
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/

upload:
	script/upload

