/**
 * Copyright (C) 2021 Masatoshi Fukunaga
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
// lua
#include <lauxlib.h>
#include <lua.h>

static int torawstring_lua(lua_State *L)
{
    switch (lua_type(L, 1)) {
    case LUA_TNONE:
        return luaL_argerror(L, 1, "argument expected, got no argument");

    case LUA_TNIL:
        lua_pushliteral(L, "nil");
        return 1;

    case LUA_TBOOLEAN:
        if (lua_toboolean(L, 1)) {
            lua_pushliteral(L, "true");
        } else {
            lua_pushliteral(L, "false");
        }
        return 1;

    case LUA_TNUMBER:
        lua_pushstring(L, lua_tostring(L, 1));
        return 1;

    case LUA_TSTRING:
        lua_pushfstring(L, "string: %p", lua_tostring(L, 1));
        return 1;

    // LUA_TLIGHTUSERDATA
    // LUA_TTABLE
    // LUA_TFUNCTION
    // LUA_TUSERDATA
    // LUA_TTHREAD
    default:
        lua_pushfstring(L, "%s: %p", lua_typename(L, lua_type(L, 1)),
                        lua_topointer(L, 1));
        return 1;
    }
}

LUALIB_API int luaopen_assert_torawstring(lua_State *L)
{
    lua_pushcfunction(L, torawstring_lua);
    return 1;
}
