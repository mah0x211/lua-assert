--
-- Copyright (C) 2021 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
local error = error
local next = next
local pcall = pcall
local tostring = tostring
local format = string.format
local lower = string.lower
local sub = string.sub
local find = string.find
local getmetatable = debug.getmetatable
local setmetatable = setmetatable
local pairs = pairs
local type = type
local flatten = require('table.flatten')
local dump = require('dump')
local isa = require('isa')
local is_boolean = isa.boolean
local is_int = isa.int
local is_finite = isa.finite
local is_nan = isa.nan
local is_string = isa.string
local is_table = isa.table
local is_nil = isa.Nil
local is_function = isa.Function
local retest = require('regex').test
local escape = require('assert.escape')
local torawstring = require('assert.torawstring')

--- dumpv returns an escaped string of a stringified data structure.
--- @param v any
--- @return string
local function dumpv(v)
    return escape(dump(v, 0))
end

--- convert2string converts a value to a string with the tostring function or
--- the __tostring meta-method call.
--- @param v any
--- @return string
local function convert2string(v)
    if not is_string(v) then
        local mt = getmetatable(v)
        if is_table(mt) and is_function(mt.__tostring) then
            return tostring(v)
        end
    end
    return v
end

local _M = {}
_M.torawstring = torawstring

--- throws expects function f to fail and returns the error raised by function f.
--- @param f function
--- @param ... any function arguments
--- @return string err
local function throws(f, ...)
    if not is_function(f) then
        error(
            format('invalid argument #1 (function expected, got %s)', type(f)),
            2)
    end

    local ok, err = pcall(f, ...)
    if ok then
        error(format("<%s> should throw an error", tostring(f)), 2)
    end
    return err
end
_M.throws = throws

--- not_throws expects function f will not fail.
--- @param f function
--- @param ... any function arguments
--- @return any res
local function not_throws(f, ...)
    if not is_function(f) then
        error(
            format('invalid argument #1 (function expected, got %s)', type(f)),
            2)
    end

    local ok, res = pcall(f, ...)
    if not ok then
        error(format("<%s> should not throw an error: %s", tostring(f), res), 2)
    end
    return res
end
_M.not_throws = not_throws

-- export funcs with lowercase names in isa module
for k, f in pairs(isa) do
    local c = sub(k, 1, 1)
    if c == lower(c) then
        _M['is_' .. k] = function(v)
            if f(v) then
                return v
            elseif type(v) ~= 'number' then
                error(format('<%s> is not %s', tostring(v), k), 2)
            elseif is_nan(v) then
                error(format('<nan> is not %s', k), 2)
            end
            error(format('<%s> is not %s', v, k), 2)
        end
        _M['not_' .. k] = function(v)
            if not f(v) then
                return v
            elseif type(v) ~= 'number' then
                error(format('<%s> is %s', tostring(v), k), 2)
            elseif is_nan(v) then
                error(format('<nan> is %s', k), 2)
            end
            error(format('<%s> is %s', v, k), 2)
        end
    end
end

--- is_empty expects v to be an empty table.
--- @param v table
--- @return boolean
local function is_empty(v)
    if not is_table(v) then
        error(format('invalid argument #1 (table expected, got %s)', type(v)), 3)
    end
    return not next(v)
end

--- empty returns v if v is an empty table, otherwise it throws an error.
--- @param v table
--- @return table v
local function empty(v)
    if is_empty(v) then
        return v
    end
    error(format('<%s> is not empty', tostring(v)), 2)
end
_M.empty = empty

--- not_empty returns v if v is not an empty table, otherwise it throws an error.
--- @param v table
--- @return table v
local function not_empty(v)
    if not is_empty(v) then
        return v
    end
    error(format('<%s> is empty', tostring(v)), 2)
end
_M.not_empty = not_empty

--- is_equal compares act and exp, and throws an error if the types of act and
--- exp are different.
--- @param act any
--- @param exp any
--- @return boolean equal
--- @return string av
--- @return string ev
local function is_equal(act, exp)
    local t1 = type(act)
    local t2 = type(exp)
    if t1 ~= t2 then
        error(format('invalid comparison #1 <%s> == #2 <%s>', t1, t2), 3)
    elseif t1 == 'number' then
        return act == exp or (is_nan(act) and is_nan(exp)), dumpv(act),
               dumpv(exp)
    end

    local av = dumpv(act)
    local ev = dumpv(exp)
    return av == ev, av, ev
end

--- equal returns act if act and exp are equal, otherwise it throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function equal(act, exp)
    local eq, av, ev = is_equal(act, exp)
    if eq then
        return act
    end
    error(format([[the two given values should be equal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.equal = equal

--- not_equal returns act if act and exp are not equal, otherwise it throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function not_equal(act, exp)
    local eq, av, ev = is_equal(act, exp)
    if not eq then
        return act
    end
    error(format([[the two given values should not be equal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.not_equal = not_equal

--- is_rawequal compares act and exp, and throws an error if the types of act
--- and exp are different.
--- @param act any
--- @param exp any
--- @return boolean equal
--- @return string av
--- @return string ev
local function is_rawequal(act, exp)
    local t1 = type(act)
    local t2 = type(exp)
    if t1 ~= t2 then
        error(format('invalid comparison #1 <%s> == #2 <%s>', t1, t2), 3)
    elseif t1 == 'number' then
        return act == exp or (is_nan(act) and is_nan(exp)), dumpv(act),
               dumpv(exp)
    end

    local av = torawstring(act)
    local ev = torawstring(exp)
    return av == ev, av, ev
end

--- rawequal returns act if act and exp are primitively equal, otherwise it
--- throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function rawequal(act, exp)
    local eq, av, ev = is_rawequal(act, exp)
    if eq then
        return act
    end
    error(format([[the two given values should be raw equal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.rawequal = rawequal

--- not_rawequal returns act if act and exp are not primitively equal, otherwise
--- it throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function not_rawequal(act, exp)
    local eq, av, ev = is_rawequal(act, exp)
    if not eq then
        return act
    end
    error(format([[the two given values should not be raw equal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.not_rawequal = not_rawequal

--- greater returns v if v is greater than x, otherwise it throws an error.
--- @param v number finite number
--- @param x number finite number
--- @return number v
local function greater(v, x)
    if not is_finite(v) or not is_finite(x) then
        error(format(
                  'invalid comparison #1 <%s> > #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 2)
    elseif v > x then
        return v
    end
    error(format('<%s> is not greater than <%s>', v, x), 2)
end
_M.greater = greater

--- greater_or_equal returns v if v is greater than or equal to x, otherwise it throws
--- an error.
--- @param v number finite number
--- @param x number finite number
--- @return number v
local function greater_or_equal(v, x)
    if not is_finite(v) or not is_finite(x) then
        error(format(
                  'invalid comparison #1 <%s> >= #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 2)
    elseif v >= x then
        return v
    end
    error(format('<%s> is not greater than or equal to <%s>', v, x), 2)
end
_M.greater_or_equal = greater_or_equal

--- less returns v if v is less than x, otherwise it throws an error.
--- @param v number finite number
--- @param x number finite number
--- @return number v
local function less(v, x)
    if not is_finite(v) or not is_finite(x) then
        error(format(
                  'invalid comparison #1 <%s> < #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 3)
    elseif v < x then
        return v
    end
    error(format('<%s> is not less than <%s>', v, x), 2)
end
_M.less = less

--- less_or_equal returns v if v is less than or equal to x, otherwise it throws
--- an error.
--- @param v number finite number
--- @param x number finite number
--- @return number v
local function less_or_equal(v, x)
    if not is_finite(v) or not is_finite(x) then
        error(format(
                  'invalid comparison #1 <%s> <= #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 3)
    elseif v <= x then
        return v
    end
    error(format('<%s> is not less than or equal to <%s>', v, x), 2)
end
_M.less_or_equal = less_or_equal

--- is_match finds a position that matches pattern in the string s.
--- @param s string
--- @param pattern string
--- @param plain? boolean default true
--- @param init? integer
--- @return number head
--- @return number tail
local function is_match(s, pattern, plain, init)
    -- set plain to true by default
    if is_nil(plain) then
        plain = true
    end

    s = convert2string(s)
    if not is_string(s) then
        error(format('invalid argument #1 (string expected, got %s)', type(s)),
              3)
    elseif not is_string(pattern) then
        error(format('invalid argument #2 (string expected, got %s)',
                     type(pattern)), 3)
    elseif not is_boolean(plain) then
        error(format('invalid argument #3 (boolean or nil expected, got %s)',
                     type(plain)), 3)
    elseif init and not is_int(init) then
        error(format('invalid argument #4 (integer or nil expected, got %s)',
                     type(init)), 3)
    end

    return find(s, pattern, init, plain)
end

--- lua_match returns s if a pattern is found in the string s, otherwise it throws
--- an error.
--- @param s string
--- @param pattern string
--- @param plain boolean|nil
--- @param init integer
--- @return string s
local function lua_match(s, pattern, plain, init)
    if is_match(s, pattern, plain, init) then
        return s
    end
    error(format([[the given string should match a pattern:
subject: %q
pattern: %q
  plain: %s
   init: %s
]], tostring(s), pattern, tostring(is_nil(plain) or plain), tostring(init)), 2)
end
_M.match = lua_match

--- not_match returns s if a pattern is not found in the string s, otherwise it
--- throws an error.
--- @param s string
--- @param pattern string
--- @param plain boolean|nil
--- @param init integer
--- @return string s
local function not_lua_match(s, pattern, plain, init)
    if not is_match(s, pattern, plain, init) then
        return s
    end
    error(format([[the given string should not match a pattern:
subject: %q
pattern: %q
  plain: %s
   init: %s
]], tostring(s), pattern, tostring(is_nil(plain) or plain), tostring(init)), 2)
end
_M.not_match = not_lua_match

--- is_re_match tests whether a regular expression pattern can be found in the string s.
--- @param s string
--- @param pattern string
--- @param flgs string
--- @param offset integer
--- @return boolean
local function is_re_match(s, pattern, flgs, offset)
    s = convert2string(s)
    if not is_string(s) then
        error(format('invalid argument #1 (string expected, got %s)', type(s)),
              3)
    elseif not is_string(pattern) then
        error(format('invalid argument #2 (string expected, got %s)',
                     type(pattern)), 3)
    elseif flgs and not is_string(flgs) then
        error(format('invalid argument #3 (string or nil expected, got %s)',
                     type(flgs)), 3)
    elseif offset and not is_int(offset) then
        error(format('invalid argument #4 (integer or nil expected, got %s)',
                     type(offset)), 3)
    end

    local ok, err = retest(s, pattern, flgs, offset)
    if err then
        error(format("failed to call regex.test: %s", err), 3)
    end

    return ok
end

--- re_match returns s if a regular expression pattern is found in the string s,
--- otherwise it throws an error.
--- @param s string
--- @param pattern string
--- @param flgs string
--- @param offset integer
--- @return string
local function re_match(s, pattern, flgs, offset)
    if is_re_match(s, pattern, flgs, offset) then
        return s
    end

    error(format([[the given string should match a regular expression pattern:
subject: %q
pattern: %q
  flags: %q
 offset: %s
]], tostring(s), pattern, tostring(flgs), tostring(offset)), 2)
end
_M.re_match = re_match

--- not_re_match returns s if a regular expression pattern is not found in the
--- string s, otherwise it throws an error.
--- @param s string
--- @param pattern string
--- @param flgs string
--- @param offset integer
--- @return string
local function not_re_match(s, pattern, flgs, offset)
    if not is_re_match(s, pattern, flgs, offset) then
        return s
    end

    error(format(
              [[the given string should not match a regular expression pattern:
subject: %q
pattern: %q
  flags: %q
 offset: %s
]], tostring(s), pattern, tostring(flgs), tostring(offset)), 2)
end
_M.not_re_match = not_re_match

--- is_contains tests whether a v contains the exp or not.
--- @param v any
--- @param exp any
--- @return boolean
local function is_contains(v, exp)
    if is_string(v) then
        -- verify that a v string contains an exp string
        return is_match(v, exp) ~= nil
    elseif not is_table(v) then
        -- verify that a v equal to an exp
        return is_equal(v, exp) ~= nil
    end

    local av = flatten(v)

    if not is_table(exp) then
        -- verify that a v table contains an exp value
        local t = type(exp)
        for _, val in pairs(av) do
            if type(val) == t and val == exp then
                return true
            end
        end
        return false
    end

    -- verify that a v table contains key-value pairs of an exp table
    local ev = flatten(exp)
    for key, val in pairs(ev) do
        local t = type(val)
        local aval = av[key]

        if type(aval) ~= t then
            return false
        elseif t == 'table' then
            if dumpv(aval) ~= dumpv(val) then
                return false
            end
        elseif aval ~= val then
            return false
        end
    end
    return true
end

--- contains returns v if a v contains the exp, otherwise it throws an error.
--- @param v any
--- @param exp any
--- @return boolean
local function contains(v, exp)
    if is_contains(v, exp) then
        return v
    end
    error(format([[%s is not contained in %s]], dump(exp), dump(v)), 2)
end
_M.contains = contains

--- not_contains returns v if a v not contains the exp, otherwise it throws an error.
--- @param v any
--- @param exp any
--- @return boolean
local function not_contains(v, exp)
    if not is_contains(v, exp) then
        return v
    end
    error(format([[%s is contained in %s]], dump(exp), dump(v)), 2)
end
_M.not_contains = not_contains

local function __call(_, v, msg, ...)
    if v == nil or v == false then
        if msg == nil then
            error('assertion failed!', 2)
        end
        error(tostring(msg), 2)
    end

    return v, msg, ...
end

local function __newindex(_, k, v)
    error(format('attempt to create a new index <%q> = <%q>', tostring(k),
                 tostring(v)), 2)
end

return setmetatable({}, {
    __call = __call,
    __newindex = __newindex,
    __index = _M,
})
