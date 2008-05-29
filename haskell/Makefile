#OOPTS = -O2 -prof -auto
OPTS= $(OOPTS) -funbox-strict-fields -fwarn-incomplete-patterns

all:
	ghc $(OPTS) -isrc --make src/RestyView.hs -o bin/restyview

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript bin/restyview
	-find -name '*.o' -delete
	-find -name '*.hi' -delete
	-find -name '*.ho' -delete

