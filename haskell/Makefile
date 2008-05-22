OPTS= -O2 -package parsec -package json -XFlexibleInstances -XOverloadedStrings
#OPTS= -package parsec -package json -XFlexibleInstances

all: bin/restyview

bin/restyview: src/RestyScript/Util.o src/RestyView/AST.o src/RestyView/Emitter/RenameVar.o src/RestyView/Emitter/RestyScript.o src/RestyView/Emitter/Fragments.o src/RestyView/Emitter/Stats.o src/RestyView/Parser.o src/RestyView.o
	cd src && ghc $(OPTS) -o ../$@ --make RestyView

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: all
	prove -r t

clean:
	-rm bin/restyscript bin/restyview
	-find -name '*.o' -delete
	-find -name '*.hi' -delete
	-find -name '*.ho' -delete

