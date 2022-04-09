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


## err = assert.throws(f, ...)

throws expects function `f` to fail and returns the error raised by function `f`.


## v = assert.is_boolean(v)

asserts that `v` is `boolean`.


## v = assert.is_true(v)

asserts that `v` is `true`.


## v = assert.is_false(v)

asserts that `v` is `false`.


## v = assert.is_nil(v)

asserts that `v` is `nil`.


## v = assert.is_none(v)

asserts that `v` is `none`.

**NOTE:** `nil`, `false`, `0`, `''` and `nan` values are evaluated as `none`.


## v = assert.is_nan(v)

asserts that `v` is `nan`.


## v = assert.is_finite(v)

asserts that `v` is `finite number`.


## v = assert.is_unsigned(v)

asserts that `v` is `unsigned number`.


## v = assert.is_int(v)

asserts that `v` is `int`.


## v = assert.is_int8(v)

asserts that `v` is `int8`. (from `-128` to `127`)


## v = assert.is_int16(v)

asserts that `v` is `int8`. (from `-32768` to `32767`)


## v = assert.is_int32(v)

asserts that `v` is `int8`. (from `-2147483648` to `2147483647`)

## v = assert.is_uint(v)

asserts that `v` is `uint`.


## v = assert.is_uint8(v)

asserts that `v` is `int8`. (from `0` to `255`)


## v = assert.is_uint16(v)

asserts that `v` is `int8`. (from `0` to `65535`)


## v = assert.is_uint32(v)

asserts that `v` is `int8`. (from `0` to `4294967295`)


## v = assert.empty(v)

empty returns `v` if `v` is an empty table, otherwise it throws an error.


## v = assert.not_empty(v)

not_empty returns `v` if `v` is not an empty table, otherwise it throws an error.


## v = assert.equal(v, expected)

equal returns `v` if `v` and `expected` are equal, otherwise it throws an error.


## v = assert.not_equal(v, expected)

not_equal returns `v` if `v` and `expected` are not equal, otherwise it throws an error.


## v = assert.equal_string(v, expected)

equal returns `v` if `tostring(v)` and `tostring(expected)` are equal, otherwise it throws an error.


## v = assert.not_equal_string(v, expected)

not_equal returns `v` if `tostring(v)` and `tostring(expected)` are not equal, otherwise it throws an error.


## v = assert.rawequal(v, expected)

rawequal returns `v` if `v` and `expected` are primitively equal, otherwise it throws an error.


## v = assert.not_rawequal(v, expected)

rawequal returns `v` if `v` and `expected` are not primitively equal, otherwise it throws an error.


## v = assert.greater(v, x)

greater returns `v` if `v` is greater than `x`, otherwise it throws an error.


## v = assert.greater_or_equal(v, x)

greater_or_equal returns `v` if `v` is greater than or equal to `x`, otherwise it throws an error.


## v = assert.less(v, x)

less returns `v` if `v` is less than `x`, otherwise it throws an error.


## v = assert.less_or_equal(v, x)

greater_or_equal returns `v` if `v` is less than or equal to `x`, otherwise it throws an error.


## s = assert.match(s, pattern, plain, init)

match returns `s` if a `pattern` is found in the string `s`, otherwise it throws an error.

**NOTE:** the arguments are the same as for the `string.find` function.


## s = assert.not_match(s, pattern, plain, init)

not_match returns `s` if a `pattern` is not found in the string `s`, otherwise it throws an error.


## s = assert.re_match(s, pattern, flags, offset)

re_match returns `s` if a regular expression `pattern` is found in the string `s`, otherwise it throws an error.

**NOTE:** the arguments are the same as for the [regexp.test](https://github.com/mah0x211/lua-regex#ok-err--regextest-sbj-pattern--flgs--offset-) function.


## s = assert.not_re_match(s, pattern, flags, offset)

not_re_match returns `s` if a regular expression `pattern` is not found in the string `s`, otherwise it throws an error.


## v = assert.contains(v, expected)

contains returns `v` if a `v` contains the `expected`, otherwise it throws an error.


## v = assert.not_contains(v, expected)

not_contains returns `v` if a `v` not contains the `expected`, otherwise it throws an error.
