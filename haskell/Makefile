all: bin/restyscript

bin/restyscript: src/RestyScript/AST.o src/RestyScript/Emitter.o src/RestyScript/Parser.o src/RestyScript.o src/Main.o
	cd src && ghc -package parsec -o ../$@ --make Main

%.o: %.hs
	cd src && ghc -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript
	-find -name '*.o' -delete
	-find -name '*.hi' -delete

