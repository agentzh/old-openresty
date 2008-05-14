all: restyscript

restyscript: RestyScript.o Main.o
	ghc -package parsec -o $@ $^

%.o: %.hs
	ghc -c $<

test: all
	prove sanity.t

