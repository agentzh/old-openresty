year=2008
month=07
day=04
html_file=stats-$(year)$(month)$(day).html

all: $(html_file)

$(html_file): stats.html
	cp $< $@

%.html: %.pod
	podhtm --index --css perl.css -o $@ $<

%.pod: %.podx
	DSN=dbi:Pg:dbname=test /usr/local/bin/podx -u agentzh -p agentzh $<

%.podx: %.tt
	tpage --define year=$(year) --define month=$(month) --define day=$(day) $< > $@

upload: $(html_file)
	scp -P 18888 -l 10000 $(html_file) agentzh@agentzh.org:~/misc/logs/

import:
	perl import.pl ced02 ced02/$(year)/$(month)/$(day)/*.log

