.PHONY: restyscript openhesty test-openhesty
#POPTS = -prof -auto-all -fhpc
OPTS= $(OOPTS) $(POPTS) -funbox-strict-fields -fwarn-incomplete-patterns

restyscript:
	ghc -i $(OPTS) -isrc --make Main -o bin/restyscript

%.o: %.hs
	cd src && ghc $(OPTS) -c ../$<

test: restyscript
	prove -r t

clean:
	-rm bin/restyscript
	-rm `find -name '*.o'` `find -name '*.hi'` `find -name '*.ho'`

static: OOPTS = -static -optl-static -optl-pthread -O2 -fvia-c -optc-O2
static: restyscript

optimized: OOPTS = -O2
optimized: restyscript

optimized2: OOPTS = -O2 -fvia-c -optc-O2 #-fdicts-cheap -fno-method-sharing -fmax-simplifier-iterations10 -fliberate-case-threshold100 -optc-mtune=pentinum4
optimized2: restyscript

openhesty:
	ghc -i $(OPTS) -isrc --make src/OpenResty.hs -o bin/openhesty

all: restyscript openhesty

test-openhesty: openhesty
	sudo /etc/init.d/lighttpd restart
	@echo "===================="
	curl 'http://localhost/==/foo/bar'
	@echo "===================="
	curl 'http://localhost/=/你好.gif?foo=bar&bar=foo'
	@echo "===================="
	echo 'data=hello' | lwp-request -m POST 'http://localhost/=/你好.gif?foo=bar&data=hello&bar=foo'
	@echo "===================="
	echo 'hello' | lwp-request -m POST -c 'text/plain' 'http://localhost/=/你好.gif?foo=bar&bar=foo'
	@echo "===================="
	time echo '章亦春' | lwp-request -m POST -c 'text/plain' 'http://localhost/=/model/Foo/~/~.gif?foo=bar&bar=foo'
	@echo "===================="
	curl 'http://localhost/=/model/Foo/col/你好.yaml?foo=小明&bar=小红'
	@echo "===================="
	curl 'http://localhost/=/你好.yml?foo=小明&bar=小红'
	@echo "===================="
	curl 'http://localhost/=/'
	@echo "===================="
	curl 'http://localhost/=/put/'
	@echo "===================="
	curl 'http://localhost/=/put//'

