# lua-assert

[![test](https://github.com/mah0x211/lua-assert/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-assert/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/mah0x211/lua-assert/branch/master/graph/badge.svg)](https://codecov.io/gh/mah0x211/lua-assert)

simple assertion module for lua.

## Installation

```sh
luarocks install assert
```

***

## assert (v [, message])

issues an error when the value of its argument `v` is `false` (i.e., `nil` or `false`); otherwise, returns all its arguments. `message` is an error message; when absent, it defaults to `"assertion failed!"`.


## Expects the function to throw [not to throw] an error.

| function | description |
| --- | --- |
| `err = throws(fn, ...)` | expects that the function `fn` to throw an error and returns the error message raised by function `fn`. |
| `res = not_throws(fn, ...)` | expects that the function `fn` will not throw an error and returns the return value of function `fn`. |

```lua
local assert = require('assert')

local function fn(v)
    if v == nil then
        error('v is nil')
    end
    return v
end

-- fn throws an error 'v is nil'
local err = assert.throws(fn)
print(err) -- ./example.lua:5: v is nil
-- fn returns 'hello'
local v = assert.not_throws(fn, 'hello')
print(v) -- hello

assert.throws(fn, 'hello') -- assertion failed!
-- lua: ./example.lua:17: <function: 0x600000be1020> should throw an error
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:86: in field 'throws'
-- 	./example.lua:17: in main chunk
-- 	[C]: in ?
```


## Expects the value to be [not to be] of a specific type.

| function | description |
| --- | --- |
| `v = is_nil(v)` | expects that `v` is `nil`. |
| `v = not_nil(v)` | expects that `v` is not `nil`. |
| `v = is_boolean(v)` | expects that `v` is `boolean`. |
| `v = not_boolean(v)` | expects that `v` is not `boolean`. |
| `v = is_string(v)` | expects that `v` is `string`. |
| `v = not_string(v)` | expects that `v` is not `string`. |
| `v = is_table(v)` | expects that `v` is `table`. |
| `v = not_table(v)` | expects that `v` is not `table`. |
| `v = is_function(v)` | expects that `v` is `function`. |
| `v = not_function(v)` | expects that `v` is not `function`. |
| `v = is_thread(v)` | expects that `v` is `thread`. |
| `v = not_thread(v)` | expects that `v` is not `thread`. |
| `v = is_userdata(v)` | expects that `v` is `userdata`. |
| `v = not_userdata(v)` | expects that `v` is not `userdata`. |
| `v = is_file(v)` | expects that `v` is `file`. |
| `v = not_file(v)` | expects that `v` is not `file`. |
| `v = is_number(v)` | expects that `v` is `number`. |
| `v = not_number(v)` | expects that `v` is not `number`. |

```lua
local assert = require('assert')

assert.is_table({})
assert.not_table({}) -- assertion failed!
-- lua: ./example.lua:4: <table: 0x6000038d92c0> is table
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:129: in field 'not_table'
-- 	./example.lua:4: in main chunk
-- 	[C]: in ?
```


## Expects the value to be [not to be] of a specific value.

| function | description |
| --- | --- |
| `v = is_none(v)` | expects that `v` is `none`.<br>`nil`, `false`, `0`, `''` and `nan` values are evaluated as `none`. |
| `v = not_none(v)` | expects that `v` is not `none`. |
| `v = is_true(v)` | expects that `v` is `true`. |
| `v = not_true(v)` | expects that `v` is not `true`. |
| `v = is_false(v)` | expects that `v` is `false`. |
| `v = not_false(v)` | expects that `v` is not `false`. |
| `v = is_nan(v)` | expects that `v` is `nan`. |
| `v = not_nan(v)` | expects that `v` is not `nan`. |
| `v = is_fininte(v)` | expects that `v` is `finite number`. |
| `v = not_fininte(v)` | expects that `v` is not `finite number`. |
| `v = is_unsigned(v)` | expects that `v` is `unsigned number`. |
| `v = not_unsigned(v)` | expects that `v` is not `unsigned number`. |
| `v = is_int(v)` | expects that `v` is `int`. |
| `v = not_int(v)` | expects that `v` is not `int`. |
| `v = is_int8(v)` | expects that `v` is `int8`. (from `-128` to `127`) |
| `v = not_int8(v)` | expects that `v` is not `int8`.  |
| `v = is_int16(v)` | expects that `v` is `int16`. (from `-32768` to `32767`) |
| `v = not_int16(v)` | expects that `v` is not `int16`. |
| `v = is_int32(v)` | expects that `v` is `int32`.  (from `-2147483648` to `2147483647`) |
| `v = not_int32(v)` | expects that `v` is not `int32`. |
| `v = is_uint(v)` | expects that `v` is `uint`. |
| `v = not_uint(v)` | expects that `v` is not `uint`.  |
| `v = is_uint8(v)` | expects that `v` is `uint8`. (from `0` to `255`) |
| `v = not_uint8(v)` | expects that `v` is not `uint8`. |
| `v = is_uint16(v)` | expects that `v` is `uint16`. (from `0` to `65535`) |
| `v = not_uint16(v)` | expects that `v` is not `uint16`. |
| `v = is_uint32(v)` | expects that `v` is `uint32`. (from `0` to `4294967295`) |
| `v = not_uint32(v)` | expects that `v` is not `uint32`. |

```lua
local assert = require('assert')

assert.is_true(true)
assert.not_true(true) -- assertion failed!
-- lua: ./example.lua:4: <true> is true
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:129: in field 'not_true'
-- 	./example.lua:4: in main chunk
-- 	[C]: in ?
```


## Expects the table to have [not have] a specific key.

| function | description |
| --- | --- |
| `v = empty(v)` | expects that `v` is an empty table. |
| `v = not_empty(v)` | expects that `v` is not an empty table. |

these functions do not check the `metatable`.

```lua
local assert = require('assert')

assert.empty({})
assert.not_empty({}) -- assertion failed!
-- lua: ./example.lua:4: <table: 0x600000adae40> is empty
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:166: in field 'not_empty'
-- 	./example.lua:4: in main chunk
-- 	[C]: in ?
```


## Expects the value equal to [not equal to] the expected value.

| function | description |
| --- | --- |
| `v = equal(v, expected)` | expects that `v` and `expected` are equal. |
| `v = not_equal(v, expected)` | expects that `v` and `expected` are not equal. |
| `v = rawequal(v, expected)` | expects that `v` and `expected` are raw equal. |
| `v = not_rawequal(v, expected)` | expects that `v` and `expected` are not raw equal. |

```lua
local assert = require('assert')

assert.equal({}, {})
assert.not_equal({}, {'foo'})
assert.equal({'foo'}, {'bar'}) -- assertion failed!
-- lua: ./example.lua:5: the two given values should be equal:
--   actual: "{ [1] = \"foo\" }"
-- expected: "{ [1] = \"bar\" }"
--
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:201: in field 'equal'
-- 	./example.lua:7: in main chunk
-- 	[C]: in ?
```


## Expect the result of a numerical comparison to be [not be] true.

| function | description |
| --- | --- |
| `v = greater(v, expected)` | expects that `v` is greater than `expected`. |
| `v = greater_or_equal(v, expected)` | expects that `v` is greater than or equal to `expected`. |
| `v = less(v, expected)` | expects that `v` is less than `expected`. |
| `v = less_or_equal(v, expected)` | expects that `v` is less than or equal to `expected`. |

```lua
local assert = require('assert')

assert.greater(4, 1)
assert.greater_or_equal(3, 3)
assert.less(3, 1) -- assertion failed!
-- lua: ./example.lua:5: <3> is not less than <1>
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:325: in field 'less'
-- 	./example.lua:5: in main chunk
-- 	[C]: in ?
```


## Expect the string value to match [not match] the pattern.

| function | description |
| --- | --- |
| `s = match(s, pattern, plain, init)` | expects that `s` matches the `pattern`. |
| `s = not_match(s, pattern, plain, init)` | expects that `s` does not match the `pattern`. |
| `s = re_match(s, pattern, flags, offset)` | expects that `s` matches the regular expression `pattern`. |
| `s = not_re_match(s, pattern, flags, offset)` | expects that `s` does not match the regular expression `pattern`. |

**NOTE:** 

- the arguments of `match` and `not_match` functions are the same as for the `string.find` function, and `plain` argument is default to `true`.
- the arguments of `re_match` and `not_re_match` functions are the same as for the `regex.test` function of `lua-regex` module https://github.com/mah0x211/lua-regex

```lua
local assert = require('assert')

assert.match('hello world', 'world')
assert.match('hello world', '%sworld', false)
assert.not_match('hello world', 'o%sw')
assert.not_match('hello world', 'o%sw', false) -- assertion failed!
-- lua: ./example.lua:6: the given string should not match a pattern:
-- subject: "hello world"
-- pattern: "o%sw"
--   plain: false
--    init: nil
--
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:408: in field 'not_match'
-- 	./example.lua:6: in main chunk
-- 	[C]: in ?
```


## Expect the value contains [not contains] the expected value.

| function | description |
| --- | --- |
| `v = contains(v, expected)` | expects that `v` contains the `expected`. |
| `v = not_contains(v, expected)` | expects that `v` not contains the `expected`. |

**NOTE:**

- if `v` is a `string`, the `expected` is treated as a substring.
- if `v` is not a `table`, `expected` is treated as the value to be compared.
- if `v` is a `table`
    - if `expected` is not a `table`, search for v containing the same value as `expected`.
    - if `expected` is a `table`, search for v containing the same key-value pairs as `expected`.

```lua
local assert = require('assert')

assert.contains('hello world', 'world')
assert.contains({
    hello = 'world',
}, 'world')
assert.contains({
    foo = {
        bar = 'baz',
        qux = 'quux',
    },
    hello = {
        world = '!',
        contains = 123,
    },
}, {
    foo = {
        bar = 'baz',
    },
    hello = {
        contains = 123,
    },
})
assert.not_contains({
    hello = 'world',
}, 'world') -- assertion failed!
-- lua: ./example.lua:24: "world" is contained in {
--     hello = "world"
-- }
-- stack traceback:
-- 	[C]: in function 'error'
-- 	./assert.lua:555: in field 'not_contains'
-- 	./example.lua:24: in main chunk
-- 	[C]: in ?
```
