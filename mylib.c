#include <errno.h>
#include <string.h>

#include <stdlib.h>
#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>
#include <lua5.1/lauxlib.h>

static int C_alloc(lua_State* L) {
	lua_Integer n = luaL_checkinteger(L, 1);
	lua_Integer s = luaL_checkinteger(L, 2);
	void *data = calloc(n, s);
	if (data == NULL) {
		/* error handle */
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	lua_pushlightuserdata(L, data);
	return 1;
}

static luaL_Reg mylib[] = {
	{"calloc", C_alloc},
	{NULL, NULL}
};

int luaopen_mylib(lua_State* L) {
	luaL_register(L, "mylib", mylib);
	return 1;
}
