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

static int escape_lua(lua_State *L)
{
    static const char dec2hex[17] = "0123456789abcdef";
    size_t len                    = 0;
    const char *str               = luaL_checklstring(L, 1, &len);
    unsigned char *p              = (unsigned char *)str;
    char buf[BUFSIZ];
    size_t head = 0;
    int argc    = 0;

    if (!len) {
        lua_pushliteral(L, "");
        return 1;
    }

    // WARNING: In lua 5.3 and later, values passed to C functions are also
    // subject to gc, so the value should not be removed from the stack while
    // it is in use.
    lua_settop(L, 1);
    for (size_t i = 0; i < len; i++) {
        unsigned char c = p[i];

        if (BUFSIZ - head < 5) {
            lua_pushlstring(L, buf, head);
            head = 0;
            argc++;
        }

        switch (c) {
        case 0x1 ... 0x6:
        case 0xe ... 0x1f:
        case 0x7f:
            buf[head++] = '\\';
            buf[head++] = 'x';
            buf[head++] = dec2hex[c >> 4];
            buf[head++] = dec2hex[c & 0xf];
            break;

        case '\0':
            buf[head++] = '\\';
            buf[head++] = '0';
            break;
        case '\a':
            buf[head++] = '\\';
            buf[head++] = 'a';
            break;
        case '\b':
            buf[head++] = '\\';
            buf[head++] = 'b';
            break;
        case '\t':
            buf[head++] = '\\';
            buf[head++] = 't';
            break;
        case '\n':
            buf[head++] = '\\';
            buf[head++] = 'n';
            break;
        case '\v':
            buf[head++] = '\\';
            buf[head++] = 'v';
            break;
        case '\f':
            buf[head++] = '\\';
            buf[head++] = 'f';
            break;
        case '\r':
            buf[head++] = '\\';
            buf[head++] = 'r';
            break;

        case '\\':
            if (p[i + 1] <= 0x1f || p[i + 1] == 0x7f) {
                continue;
            }

        default:
            buf[head++] = c;
        }
    }

    if (head) {
        lua_pushlstring(L, buf, head);
        argc++;
    }

    lua_concat(L, argc);
    return 1;
}

LUALIB_API int luaopen_assert_escape(lua_State *L)
{
    lua_pushcfunction(L, escape_lua);
    return 1;
}
