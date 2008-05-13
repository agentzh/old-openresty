all: restyscript

restyscript: Main.o RestyScript.o
	ghc -package parsec -o $@ $^

%.o: %.hs
	ghc -c $<

test: all
	prove sanity.t

run: all
	@echo ----------------------------
	-./restyscript ''
	@echo ----------------------------
	-./restyscript '
	@echo ----------------------------
	-./restyscript ''
	@echo ----------------------------
	-./restyscript '

