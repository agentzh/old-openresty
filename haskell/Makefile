all: restyscript

restyscript: Main.o RestyScript.o
	ghc -package parsec -o $@ $^

%.o: %.hs
	ghc -c $<

test: all
	-./restyscript 'select foo, bar from Bah'

