all: restyscript

restyscript: Main.o RestyScript.o
	ghc -package parsec -o $@ $^

%.o: %.hs
	ghc -c $<

