all:
	-cp ../../clients/js/*.js .
	jemplate --compile template/elem/ > jemplates.js
	jemplate --runtime > Jemplate.js
	tpage template/index.tt > index.html

