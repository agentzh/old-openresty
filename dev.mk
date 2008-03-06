define CMDS
    -perl bin/revision.pl
    -perl -Iblib -c bin/openresty
    -sudo killall lighttpd
    sudo /etc/init.d/lighttpd restart
    rm  -f t/cur-timer.dat
    -time prove -Ilib -r t
    bin/perf
endef

all: lib/OpenResty/MiniSQL/Select.pm

lib/OpenResty/MiniSQL/Select.pm: grammar/Select.yp
	yapp -m OpenResty::MiniSQL::Select -o $@ $<

test: all
	$(CMDS)

debug: all
	sudo echo > /var/log/lighttpd/error.log
	$(CMDS)
	cat /var/log/lighttpd/error.log | egrep -v '^$$'

%.t: all force
	sudo echo > /var/log/lighttpd/error.log
	perl -c bin/openresty.pl
	sudo /etc/init.d/lighttpd restart
	-time prove -Ilib $@
	cat /var/log/lighttpd/error.log | egrep -v '^$$'

force:

