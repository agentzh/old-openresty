all:
	-cp ../../clients/js/*.js .
	jemplate --compile template/elem/ > jemplates.js
	jemplate --runtime > Jemplate.js
	tpage --include_path=template template/index.tt > index.html


