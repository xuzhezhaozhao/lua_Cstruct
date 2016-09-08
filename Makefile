all:
	gcc -fPIC -shared clib.c -o clib.so

clean:
	rm -rf clib.so

test: all
	lua5.1 test.lua
