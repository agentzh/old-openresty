#OPTS= -O2 -package parsec
OPTS= -package parsec

all: bin/restyscript

bin/restyscript: src/RestyScript/AST.o src/RestyScript/Emitter/RestyScript.o src/RestyScript/Emitter/Stats.o src/RestyScript/Parser.o src/Main.o
	cd src && ghc $(OPTS) -o ../$@ --make Main

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript
	-find -name '*.o' -delete
	-find -name '*.hi' -delete
	-find -name '*.ho' -delete

