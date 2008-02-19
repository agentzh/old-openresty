all:
	-cp ../../clients/js/*.js .
	jemplate --compile template/elem/ > jemplates.js
	jemplate --runtime > Jemplate.js
	tpage --define 'blog_name=Human & Machine' \
	    --define 'blog_desc=The mad house for a Perl guy, agentzh' \
	    --include_path=template template/index.tt > index.html

