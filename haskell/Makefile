#POPTS = -prof -auto-all -fhpc
OPTS= $(OOPTS) $(POPTS) -funbox-strict-fields -fwarn-incomplete-patterns

all:
	ghc -i $(OPTS) -isrc --make Main -o bin/restyscript

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript
	-rm `find -name '*.o'` `find -name '*.hi'` `find -name '*.ho'`

optimized: OOPTS = -O2
optimized: all

optimized2: OOPTS = -fvia-c -optc-O3 -O2
optimized2: all

