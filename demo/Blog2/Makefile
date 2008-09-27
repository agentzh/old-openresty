.PHONY: all pack upload upload2

blog_name=EEEE Works Blog
blog_desc=Welcome to our 4E planet!
blog_owner=eeee
resty_server=localhost

all:
	-rm -rf out
	-rm -rf js
	-rm -rf template
	-mkdir out
	-cp ../../clients/js/*.js out/
	cp -r ../Blog/template .
	cp -r ../Blog/js .
	cp ../Blog/script/init.pl script/
	cp ../Blog/image/loading.gif out/
	cp ../Blog/script/reset.mk script/
	sed -i 's/resty\.eeeeworks\.org/api.eeeeworks.org/g' js/blog.js
	sed -i 's/agentzh/eeee/g' js/blog.js
	jemplate --runtime > out/blog-jemplate.js
	jemplate --compile template/elem/ >> out/blog-jemplate.js
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --define 'resty_server=$(resty_server)' \
	    --include_path=template template/index.tt > out/index.html
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	cp -r css/themes out/
	-cp -r image/*.* out/
	cp out/blog.js blog.js
	sed -i 's/\b10\.62\.136\.86\b/api.eeeeworks.org/g' out/blog.js
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/
	mv blog.js out/

pack: all
	-rm -rf pack_out
	mkdir pack_out
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --define 'resty_server=$(resty_server)' \
	    --define 'pack_js=1' \
	    --include_path=template template/index.tt > out/index.html
	cp -r out/* pack_out/
	for file in `find out -name '*.js' | grep -v 'jquery.js'`; do echo "packing $$file..."; cat $$file | jsmin > pack_out/`basename $$file`; done
	cat pack_out/blog-jemplate.js pack_out/openresty.js pack_out/blog.js > pack_out/blog_min.js
	cat pack_out/jquery.js pack_out/dojo.openresty.js > pack_out/jquery-dojo.js
	rm pack_out/blog-jemplate.js pack_out/openresty.js pack_out/blog.js
	rm -rf out
	mv pack_out out

upload: resty_server=api.eeeeworks.org
upload: all
	script/upload

upload2: resty_server=api.eeeeworks.org
upload2: pack
	script/upload out

