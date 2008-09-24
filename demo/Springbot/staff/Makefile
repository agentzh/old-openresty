.PRECIOUS: staff.txt

all: staff.csv

%.csv: %.txt
	./txt2csv.pl $< > $@

staff.txt: rolldata.sql
	./sql2txt.pl $< > $@

#%.txt: %.html
#./html2txt.pl $< > $@

