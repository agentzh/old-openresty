define CMDS
    -perl bin/revision.pl
    -perl -Iblib -c bin/openresty
    -sudo killall lighttpd
    sudo /etc/init.d/lighttpd restart
    sleep 2
    -sudo rm -rf /tmp/FileCache
    -rm  -f t/cur-timer.dat
    -time prove -Ilib -r t
    bin/perf
endef

all: lib/OpenResty/RestyScript/View.pm

lib/OpenResty/RestyScript/View.pm: grammar/restyscript-view.yp
	yapp -m OpenResty::RestyScript::View -o $@ $<

test: all
	$(CMDS)

debug: all
	$(CMDS)

%.t: all force
	perl -c bin/openresty
	sudo /etc/init.d/lighttpd restart
	-sudo rm -rf /tmp/FileCache
	-rm  -f t/cur-timer.dat
	-prove -Ilib $@
	bin/perf

force:

today=$(shell date '+%Y%m%d')
version=$(shell tail -n1 META.yml | awk '{print $$2}')
par_dir=openresty-$(version)-$(today)
par_file=$(par_dir).par

par:
	(echo ''; echo 'exit') | pp -p -x -I lib -M Crypt::Rijndael -M OpenResty::Backend::PgFarm -M GD::SecurityImage -M OpenResty::FastCGI -M HTTP::Server::Simple -M Cache::Cache -M Term::ReadKey -M Cache::Memcached::Fast -o $(par_file) bin/openresty
	@echo
	@echo $(par_file) generated.
	-rm -rf $(par_dir)
	-mkdir $(par_dir)
	cp $(par_file) $(par_dir)/
	cd $(par_dir) && unzip -q $(par_file)
	rm $(par_dir)/$(par_file)
	chmod a+x $(par_dir)/script/openresty
	cd $(par_dir) && mkdir -p haskell/bin etc font
	cp haskell/bin/restyscript $(par_dir)/haskell/bin/
	cp etc/*.conf $(par_dir)/etc/
	cp font/*.ttf $(par_dir)/font/
	tar cf $(par_dir).tar $(par_dir)
	gzip --best -f $(par_dir).tar
	rm $(par_file)
	rm -rf $(par_dir)
	echo $(par_dir).tar.gz generated.

