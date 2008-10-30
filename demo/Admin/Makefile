.PHONY: all pack upload upload2

all:
	-rm -rf out
	-mkdir out
	-cp ../../clients/js/*.js out/
	-rm template/elem/*.tt~
	-cp image/*.* out/
	jemplate --runtime > out/admin-jemplate.js
	jemplate --compile template/elem/ >> out/admin-jemplate.js
	tpage --include_path=template template/index.tt > out/index.html
	tpage --include_path=template template/login.tt > out/login.html
	tpage --define cat=model template/js/handlers.tt > out/model.js
	tpage --define cat=view template/js/handlers.tt > out/view.js
	tpage --define cat=role template/js/handlers.tt > out/role.js
	tpage --define cat=feed template/js/handlers.tt > out/feed.js
	tpage --define cat=action template/js/handlers.tt > out/action.js
	tpage template/js/dispatcher.tt > out/dispatcher.js
	cp ../Blog/image/loading.gif out/
	cp js/*.js out/
	cp js/*/*.js out/
	cp css/*.css out/
	-cp image/*.* out/
	tar cf site-binary.tar out
	gzip -q --best site-binary.tar
	mv site-binary.tar.gz out/

pack: all
	-rm -rf pack_out
	mkdir pack_out
	tpage --define pack_js=1 --include_path=template template/index.tt > out/index.html
	tpage --define pack_js=1 --include_path=template template/login.tt > out/login.html
	cp -r out/* pack_out/
	for file in `find out -name '*.js' | grep -v 'jquery'`; do echo "packing $$file..."; cat $$file | jsmin > pack_out/`basename $$file`; done
	cat pack_out/jquery.js > pack_out/jquery-min.js
	echo >> pack_out/jquery-min.js
	cat pack_out/jquery.jeditable.pack.js >> pack_out/jquery-min.js
	echo >> pack_out/jquery-min.js
	cat pack_out/jquery.cookie.pack.js >> pack_out/jquery-min.js
	rm pack_out/jquery.js pack_out/jquery.*.js
	cat pack_out/admin-jemplate.js pack_out/md5.js pack_out/dojo.openresty.js pack_out/openresty.js pack_out/model.js pack_out/view.js pack_out/role.js pack_out/feed.js pack_out/action.js pack_out/dispatcher.js pack_out/admin.js > pack_out/admin-min.js
	cat pack_out/md5.js pack_out/openresty.js pack_out/login.js > pack_out/login-min.js
	-rm pack_out/login.js
	-rm pack_out/admin-jemplate.js pack_out/md5.js pack_out/openresty.js pack_out/model.js pack_out/view.js pack_out/role.js pack_out/feed.js pack_out/action.js pack_out/dispatcher.js pack_out/admin.js pack_out/dojo.openresty.js
	rm -rf out
	mv pack_out out

upload2: pack
	script/upload

upload: all
	script/upload

