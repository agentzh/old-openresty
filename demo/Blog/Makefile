MY_DIR=~/hack/openapi/trunk/demo/Blog
all:
	-cp $(MY_DIR)/../../clients/js/*.js .
	jemplate --compile template/elem/ > jemplates.js
	jemplate --runtime > Jemplate.js
	tpage template/index.tt > index.html

