blog_name=EEEE Works Blog
blog_desc=Welcome to our 4E planet!
blog_owner=eeee

all:
	-rm -rf out
	-rm -rf js
	-rm -rf template
	-mkdir out
	-cp ../../clients/js/*.js out/
	cp -r ../Blog/template .
	cp -r ../Blog/js .
	cp ../Blog/image/loading.gif image/
	sed -i 's/resty\.eeeeworks\.org/api.eeeeworks.org/g' js/blog.js
	sed -i 's/agentzh/eeee/g' js/blog.js
	jemplate --compile template/elem/ > out/jemplates.js
	jemplate --runtime > out/Jemplate.js
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --include_path=template template/index.tt > out/index.html
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	cp -r css/themes out/
	cp -r image/*.* out/
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/

upload: all
	script/upload

