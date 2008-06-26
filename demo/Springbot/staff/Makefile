.PRECIOUS: staff.txt

all: staff.csv

%.csv: %.txt
	./txt2csv.pl $< > $@

%.txt: %.html
	./html2txt.pl $< > $@

