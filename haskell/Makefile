#POPTS = -prof -auto-all -fhpc
OOPTS = -O2
OPTS= $(OOPTS) $(POPTS) -funbox-strict-fields -fwarn-incomplete-patterns

all:
	ghc -i $(OPTS) -isrc --make src/RestyScript/View.hs -o bin/restyview
	ghc -i $(OPTS) -isrc --make src/RestyScript/Action.hs -o bin/restyaction

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript bin/restyview
	-find -name '*.o' -delete
	-find -name '*.hi' -delete
	-find -name '*.ho' -delete

