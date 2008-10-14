.PHONY: all pack upload upload2

blog_name=Human & Machine
blog_desc=The mad house for a Perl guy, agentzh
blog_owner=agentzh
#resty_server=blog.agentzh.org
resty_server=localhost

all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	cp -r ../Blog/js/thirdparty/* out/
	cp -r ../Admin/js/thirdparty/jquery.cookie.pack.js out/
	cp -r js/thirdparty/* out/
	-rm out/JSON.js
	-rm template/elem/*.tt~
	jemplate --runtime > out/blogadmin-jemplate.js
	jemplate --compile template/ajax/ >> out/blogadmin-jemplate.js
	tpage --include_path=template template/login.tt > out/login.html
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --define 'resty_server=$(resty_server)' \
	    --define 'pack_js=0' \
	    --include_path=template template/index.tt > out/index.html
	-cp js/*.js out/
	-cp js/*/*.js out/
	-cp css/*.css out/
	-cp -r image/*.* out/
	-cp out/blog.js blog.js
	-sed -i 's/\b10\.62\.136\.86\b/api.eeeeworks.org/g' out/blog.js
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/
	-mv blog.js out/

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
	rm pack_out/blog-jemplate.js pack_out/openresty.js pack_out/blog.js
	rm -rf out
	mv pack_out out

upload: all
	script/upload

upload2: pack
	script/upload

doc: doc/blog_site.png

doc/blog_site.png: doc/graphviz.mk
	gvmake -f $< --layout neato --edge-len 1.5 --debug > a.dot
	sed -i 's/node \[/node [fontname="consolas", /' a.dot
	neato -Tpng a.dot > $@


