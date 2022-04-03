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
--- @vararg any
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
    error(format([[not equal:
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
    error(format([[equal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.not_equal = not_equal

--- is_rawequal returns act if act and exp are primitively equal, otherwise it
--- throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function is_rawequal(act, exp)
    local av = torawstring(act)
    local ev = torawstring(exp)
    if av == ev then
        return act
    end
    error(format([[not rawequal:
  actual: %q
expected: %q
]], av, ev), 2)
end
_M.rawequal = is_rawequal

--- not_rawequal returns act if act and exp are not primitively equal, otherwise
--- it throws an error.
--- @param act any
--- @param exp any
--- @return any act
local function not_rawequal(act, exp)
    local av = torawstring(act)
    local ev = torawstring(exp)
    if av ~= ev then
        return act
    end
    error(format([[rawequal:
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
--- @param plain boolean|nil default true
--- @param init integer
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

--- match returns s if a pattern is found in the string s, otherwise it throws
--- an error.
--- @param s string
--- @param pattern string
--- @param plain boolean|nil
--- @param init integer
--- @return string s
local function match(s, pattern, plain, init)
    if is_match(s, pattern, plain, init) then
        return s
    end
    error(format([[no match:
subject: %q
pattern: %q
  plain: %s
   init: %s
]], tostring(s), pattern, tostring(is_nil(plain) or plain), tostring(init)), 2)
end
_M.match = match

--- not_match returns s if a pattern is not found in the string s, otherwise it
--- throws an error.
--- @param s string
--- @param pattern string
--- @param plain boolean|nil
--- @param init integer
--- @return string s
local function not_match(s, pattern, plain, init)
    if not is_match(s, pattern, plain, init) then
        return s
    end
    error(format([[match:
subject: %q
pattern: %q
  plain: %s
   init: %s
]], tostring(s), pattern, tostring(is_nil(plain) or plain), tostring(init)), 2)
end
_M.not_match = not_match

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

    error(format([[no re_match:
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

    error(format([[re_match:
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
    local t1 = type(v)
    local t2 = type(exp)

    if t1 ~= t2 then
        return false
    elseif t1 ~= 'table' then
        return is_equal(v, exp)
    end

    local ev = dumpv(exp)
    if ev == dumpv(v) then
        return true
    end

    local stack = {v}
    while #stack > 0 do
        local tbl = stack[#stack]
        stack[#stack] = nil
        if ev == dumpv(tbl) then
            return true
        end

        for _, tv in pairs(tbl) do
            if type(tv) == 'table' then
                stack[#stack + 1] = tv
            end
        end
    end

    return false
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

return
    setmetatable({}, {__call = __call, __newindex = __newindex, __index = _M})
