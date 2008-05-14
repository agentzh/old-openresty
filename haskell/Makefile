all: restyscript

restyscript: src/RestyScript/AST.o src/RestyScript/Emitter.o src/RestyScript/Parser.o src/RestyScript.o src/Main.o
	ghc -package parsec -o $@ --make Main

%.o: %.hs
	ghc -c $<

test: all
	prove sanity.t

clean:
	-rm restyscript
	-find -name '*.o' -delete
	-find -name '*.hi' -delete

