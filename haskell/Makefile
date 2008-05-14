all: restyscript

restyscript: RestyScript/AST.o RestyScript/Parser.o RestyScript.o Main.o
	ghc -package parsec -o $@ --make Main

%.o: %.hs
	ghc -c $<

test: all
	prove sanity.t

