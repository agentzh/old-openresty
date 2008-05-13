all: restyscript

restyscript: Main.o RestyScript.o
	ghc -package parsec -o $@ $^

%.o: %.hs
	ghc -c $<

test: all
	-./restyscript 'select foo, bar from Bah'
	@echo ----------------------------
	-./restyscript 'select foo'
	@echo ----------------------------
	-./restyscript 'select id,name , age from  Post , Comment'

