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
// lua
#include <lauxlib.h>

static int escape_lua(lua_State *L)
{
    static const char dec2hex[17] = "0123456789abcdef";
    size_t len                    = 0;
    const char *str               = luaL_checklstring(L, 1, &len);
    unsigned char *p              = (unsigned char *)str;
    luaL_Buffer buf;

    // Keep the input rooted while buffer operations may allocate or run GC.
    lua_settop(L, 1);
    luaL_buffinit(L, &buf);
    for (size_t i = 0; i < len; i++) {
        unsigned char c = p[i];

        switch (c) {
        case 0x1 ... 0x6:
        case 0xe ... 0x1f:
        case 0x7f: {
            const char escaped[] = {'\\', 'x', dec2hex[c >> 4],
                                    dec2hex[c & 0xf]};
            luaL_addlstring(&buf, escaped, sizeof(escaped));
            break;
        }

        case '\0':
            luaL_addlstring(&buf, "\\0", 2);
            break;
        case '\a':
            luaL_addlstring(&buf, "\\a", 2);
            break;
        case '\b':
            luaL_addlstring(&buf, "\\b", 2);
            break;
        case '\t':
            luaL_addlstring(&buf, "\\t", 2);
            break;
        case '\n':
            luaL_addlstring(&buf, "\\n", 2);
            break;
        case '\v':
            luaL_addlstring(&buf, "\\v", 2);
            break;
        case '\f':
            luaL_addlstring(&buf, "\\f", 2);
            break;
        case '\r':
            luaL_addlstring(&buf, "\\r", 2);
            break;

        case '\\':
            if (p[i + 1] <= 0x1f || p[i + 1] == 0x7f) {
                continue;
            }

        default:
            luaL_addchar(&buf, c);
        }
    }

    luaL_pushresult(&buf);
    return 1;
}

LUALIB_API int luaopen_assert_escape(lua_State *L)
{
    lua_pushcfunction(L, escape_lua);
    return 1;
}
