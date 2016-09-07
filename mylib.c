#include <errno.h>
#include <string.h>

#include <stdlib.h>
#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>
#include <lua5.1/lauxlib.h>

static int C_alloc(lua_State* L) {
	lua_Integer n = luaL_checkinteger(L, 1);
	lua_Integer s = luaL_checkinteger(L, 2);
	void *p = lua_newuserdata(L, n*s);
	memset(p, 0, n*s);
	return 1;
}

static int get_number(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	double *p = (double *)(data + len*nth + offset);
	lua_pushnumber(L, (lua_Number)(*p));
	return 1;
}

static int set_number(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	lua_Number value = luaL_checknumber(L, 5);
	double *p = (double *)(data + len*nth + offset);
	(*p) = (double)value;
	return 0;
}
static int get_string(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	const char **p = (const char **)(data + len*nth + offset);
	lua_pushstring(L, *p);
	return 1;
}
static int set_string(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	const char *s = luaL_checkstring(L, 5);
	const char **p = (const char **)(data + len*nth + offset);
	(*p) = s;
	return 0;
}

static luaL_Reg mylib[] = {
	{"calloc", C_alloc},
	{"get_number", get_number},
	{"set_number", set_number},
	{"get_string", get_string},
	{"set_string", set_string},
	{NULL, NULL}
};

int luaopen_mylib(lua_State* L) {
	luaL_register(L, "mylib", mylib);
	return 1;
}
