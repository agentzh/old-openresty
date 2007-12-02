define CMDS
    perl -c openapi.pl
    sudo /etc/init.d/lighttpd restart
    -time prove -Ilib -r t
endef

all: doc/spec.html

doc/spec.html: doc/spec.pod
	cd doc && podhtm.pl --index --charset UTF-8 --css perl.css -o spec.html spec.pod

test:
	$(CMDS)

debug:
	sudo echo > /var/log/lighttpd/error.log
	$(CMDS)
	cat /var/log/lighttpd/error.log | egrep -v '^$$'

