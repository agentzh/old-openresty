define CMDS
    perl bin/revision.pl
    perl -c bin/openapi.pl
    -sudo killall lighttpd
    sudo /etc/init.d/lighttpd restart
    rm  -f t/cur-timer.dat
    -time prove -Ilib -r t
    bin/perf
endef

all: doc/spec.html lib/MiniSQL/Select.pm

doc/spec.html: doc/spec.pod
	cd doc && podhtm.pl --index --charset UTF-8 --css perl.css -o spec.html spec.pod

lib/MiniSQL/Select.pm: grammar/Select.yp
	yapp -m MiniSQL::Select -o $@ $<

test: all
	$(CMDS)

debug: all
	sudo echo > /var/log/lighttpd/error.log
	$(CMDS)
	cat /var/log/lighttpd/error.log | egrep -v '^$$'

%.t: all force
	sudo echo > /var/log/lighttpd/error.log
	perl -c bin/openapi.pl
	sudo /etc/init.d/lighttpd restart
	-time prove -Ilib $@ 
	cat /var/log/lighttpd/error.log | egrep -v '^$$'

force:

