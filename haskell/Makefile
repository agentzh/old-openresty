OPTS= -O2 -package parsec -package json -XFlexibleInstances
#OPTS= -package parsec -package json -XFlexibleInstances

all: bin/restyview

bin/restyview: src/RestyScript/Util.o src/RestyScript/AST.o src/RestyScript/Emitter/RenameVar.o src/RestyScript/Emitter/RestyScript.o src/RestyScript/Emitter/Fragments.o src/RestyScript/Emitter/Stats.o src/RestyScript/Parser.o src/Main.o
	cd src && ghc $(OPTS) -o ../$@ --make Main

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript bin/restyview
	-find -name '*.o' -delete
	-find -name '*.hi' -delete
	-find -name '*.ho' -delete

