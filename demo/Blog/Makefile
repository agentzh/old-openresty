blog_name=Human & Machine
blog_desc=The mad house for a Perl guy, agentzh
blog_owner=agentzh
#resty_server=blog.agentzh.org
resty_server=localhost

all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	jemplate --compile template/elem/ > out/jemplates.js
	jemplate --runtime > out/Jemplate.js
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --define 'resty_server=$(resty_server)' \
	    --include_path=template template/index.tt > out/index.html
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	cp -r css/themes out/
	cp -r image/*.* out/
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/

upload: resty_server=api.eeeeworks.org
upload: all
	script/upload

