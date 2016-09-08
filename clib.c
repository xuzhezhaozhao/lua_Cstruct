#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include <lua5.1/lua.h>
#include <lua5.1/lualib.h>
#include <lua5.1/lauxlib.h>

static int C_alloc(lua_State* L) {
	lua_Integer size = luaL_checkinteger(L, 1);
	void *p = malloc(size);
	if (p == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	lua_pushlightuserdata(L, p);
	return 1;
}

static int C_realloc(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	lua_Integer newsize = luaL_checkinteger(L, 2);
	void *p = realloc(data, newsize);
	if (p == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	lua_pushlightuserdata(L, p);
	return 1;
}

static int C_free(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	free(data);
	return 0;
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

static int get_bool(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	char *p = (char *)(data + len*nth + offset);
	lua_pushboolean(L, *p);
	return 1;
}

static int set_bool(lua_State* L) {
	char *data = (char *)lua_touserdata(L, 1);
	luaL_argcheck(L, data != NULL, 1, "Wrong Parameter (expected userdata).");
	lua_Integer len = luaL_checkinteger(L, 2);
	lua_Integer nth = luaL_checkinteger(L, 3);
	lua_Integer offset = luaL_checkinteger(L, 4);
	int b = lua_toboolean(L, 5);
	char *p = (char *)(data + len*nth + offset);
	(*p) = (b == 0 ? 0 : 1);
	return 0;
}

static int size_number(lua_State* L) {
	int s = sizeof(double);
	lua_pushnumber(L, s);
	return 1;
}

static int size_string(lua_State* L) {
	int s = sizeof(char *);
	lua_pushnumber(L, s);
	return 1;
}

static int size_bool(lua_State* L) {
	int s = sizeof(char);
	lua_pushnumber(L, s);
	return 1;
}

static luaL_Reg clib[] = {
	{"calloc", C_alloc},
	{"realloc", C_realloc},
	{"free", C_free},
	{"get_number", get_number},
	{"set_number", set_number},
	{"get_string", get_string},
	{"set_string", set_string},
	{"get_bool", get_bool},
	{"set_bool", set_bool},
	{"size_number", size_number},
	{"size_string", size_string},
	{"size_bool", size_bool},
	{NULL, NULL}
};

int luaopen_clib(lua_State* L) {
	luaL_register(L, "clib", clib);
	return 1;
}
