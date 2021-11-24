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
local setmetatable = setmetatable
local dump = require('dump')
local isa = require('isa')
local retest = require('regex').test
local escape = require('assertex.escape')

local function dumpv(v)
    return escape(dump(v, 0))
end

local _M = {}

local function throws(f)
    if not isa.Function(f) then
        error(
            format('invalid argument #1 (function expected, got %s)', type(f)),
            2)
    end

    local ok, err = pcall(f)
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
            elseif isa.NaN(v) then
                error(format('<nan> is not %s', k), 2)
            end
            error(format('<%s> is not %s', v, k), 2)
        end
    end
end

local function is_empty(v)
    if not isa.Table(v) then
        error(format('invalid argument #1 (table expected, got %s)', type(v)), 3)
    end
    return not next(v)
end

local function empty(v)
    if is_empty(v) then
        return v
    end
    error(format('<%s> is not empty', tostring(v)), 2)
end
_M.empty = empty

local function not_empty(v)
    if not is_empty(v) then
        return v
    end
    error(format('<%s> is empty', tostring(v)), 2)
end
_M.not_empty = not_empty

local function is_equal(act, exp)
    local t1 = type(act)
    local t2 = type(exp)
    if t1 ~= t2 then
        error(format('invalid comparison #1 <%s> == #2 <%s>', t1, t2), 3)
    end

    local av = dumpv(act, 0)
    local ev = dumpv(exp, 0)
    return av == ev, av, ev
end

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

local function greater(v, x)
    if not isa.Finite(v) or not isa.Finite(x) then
        error(format(
                  'invalid comparison #1 <%s> > #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 2)
    elseif v > x then
        return v
    end
    error(format('<%s> is not greater than <%s>', v, x), 2)
end
_M.greater = greater

local function greater_or_equal(v, x)
    if not isa.Finite(v) or not isa.Finite(x) then
        error(format(
                  'invalid comparison #1 <%s> >= #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 2)
    elseif v >= x then
        return v
    end
    error(format('<%s> is not greater than or equal to <%s>', v, x), 2)
end
_M.greater_or_equal = greater_or_equal

local function less(v, x)
    if not isa.Finite(v) or not isa.Finite(x) then
        error(format(
                  'invalid comparison #1 <%s> < #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 3)
    elseif v < x then
        return v
    end
    error(format('<%s> is not less than <%s>', v, x), 2)
end
_M.less = less

local function less_or_equal(v, x)
    if not isa.Finite(v) or not isa.Finite(x) then
        error(format(
                  'invalid comparison #1 <%s> <= #2 <%s>, argument must be the number except for infinity and nan',
                  tostring(v), tostring(x)), 3)
    elseif v <= x then
        return v
    end
    error(format('<%s> is not less than or equal to <%s>', v, x), 2)
end
_M.less_or_equal = less_or_equal

local function match(s, pattern, plain, init)
    -- set plain to true by default
    if isa.Nil(plain) then
        plain = true
    end

    if not isa.String(s) then
        error(format('invalid argument #1 (string expected, got %s)', type(s)),
              2)
    elseif not isa.String(pattern) then
        error(format('invalid argument #2 (string expected, got %s)',
                     type(pattern)), 2)
    elseif not isa.Boolean(plain) then
        error(format('invalid argument #3 (boolean or nil expected, got %s)',
                     type(plain)), 2)
    elseif init and not isa.Int(init) then
        error(format('invalid argument #4 (integer or nil expected, got %s)',
                     type(init)), 2)
    end

    local ok = find(s, pattern, init, plain)
    if ok then
        return s
    end
    error(format([[no match:
subject: %q
pattern: %q
  plain: %s
   init: %s
]], s, pattern, tostring(plain), tostring(init)), 2)
end
_M.match = match

local function re_match(s, pattern, flgs, offset)
    if not isa.String(s) then
        error(format('invalid argument #1 (string expected, got %s)', type(s)),
              2)
    elseif not isa.String(pattern) then
        error(format('invalid argument #2 (string expected, got %s)',
                     type(pattern)), 2)
    elseif flgs and not isa.String(flgs) then
        error(format('invalid argument #3 (string or nil expected, got %s)',
                     type(flgs)), 2)
    elseif offset and not isa.Int(offset) then
        error(format('invalid argument #4 (integer or nil expected, got %s)',
                     type(offset)), 2)
    end

    local ok, err = retest(s, pattern, flgs, offset)
    if ok then
        return s
    elseif err then
        error(format("failed to call regex.test: %s", err), 2)
    end

    error(format([[no re_match:
subject: %q
pattern: %q
  flags: %q
 offset: %s
]], s, pattern, tostring(flgs), tostring(offset)), 2)

end
_M.re_match = re_match

local function __call(_, v, ...)
    if v == nil or v == false then
        local msg = select(1, ...)
        if isa.String(msg) then
            error(msg, 2)
        end
        error('assertion failed!', 2)
    end

    return v, ...
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
