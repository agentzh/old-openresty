OOPTS = -O2
OPTS= $(OOPTS) -package parsec -package json -XFlexibleInstances -XOverloadedStrings -funbox-strict-fields -fwarn-incomplete-patterns

all: bin/restyview

bin/restyview: src/RestyView/Util.o src/RestyView/AST.o src/RestyView/Emitter/RenameVar.o src/RestyView/Emitter/RestyView.o src/RestyView/Emitter/Fragments.o src/RestyView/Emitter/Stats.o src/RestyView/Parser.o src/RestyView.o
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

