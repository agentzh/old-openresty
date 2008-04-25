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
	    --define 'js_pack=0' \
	    --include_path=template template/index.tt > out/index.html
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	cp -r css/themes out/
	cp -r image/*.* out/
	tar cvf site-binary.tar out
	gzip --best site-binary.tar
	mv site-binary.tar.gz out/

pack: all
	tpage --define 'blog_name=$(blog_name)' \
	    --define 'blog_desc=$(blog_desc)' \
	    --define 'blog_owner=$(blog_owner)' \
	    --define 'resty_server=$(resty_server)' \
	    --define 'pack_js=1' \
	    --include_path=template template/index.tt > out/index.html
	-rm out/packed_all.js
	mv out/jquery.js .
	cat out/*.js | jsmin > packed_all.js
	rm out/*.js
	mv packed_all.js out/
	mv jquery.js out/

upload: resty_server=api.eeeeworks.org
upload: all
	script/upload

upload2:
	scp -l 10000 -r `pwd`/out agentzh@perlcabal.org:~/public_html

doc: doc/blog_site.png

doc/blog_site.png: doc/graphviz.mk
	gvmake -f $< --layout neato --edge-len 1.5 --debug > a.dot
	sed -i 's/node \[/node [fontname="consolas", /' a.dot
	neato -Tpng a.dot > $@


