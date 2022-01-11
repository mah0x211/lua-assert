# lua-assert

[![test](https://github.com/mah0x211/lua-assert/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-assert/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/mah0x211/lua-assert/badge.svg?branch=master)](https://coveralls.io/github/mah0x211/lua-assert?branch=master)

simple assertion module for lua.

## Installation

```sh
luarocks install assert
```

## Functions

### assert (v [, message])

issues an error when the value of its argument `v` is `false` (i.e., `nil` or `false`); otherwise, returns all its arguments. `message` is an error message; when absent, it defaults to `"assertion failed!"`.


### err = assert.throws(f, ...)

asserts that the function `f` to throws an error.

### v = assert.is_boolean(v)

asserts that `v` is `boolean`.


### v = assert.is_true(v)

asserts that `v` is `true`.


### v = assert.is_false(v)

asserts that `v` is `false`.


### v = assert.is_nil(v)

asserts that `v` is `nil`.


### v = assert.is_none(v)

asserts that `v` is `none` value.  
values of `none` are `nil`, `false`, `0`, `''` and `nan`.


### v = assert.is_nan(v)

asserts that `v` is `nan`.

### v = assert.is_finite(v)

asserts that `v` is `finite number`.

### v = assert.is_unsigned(v)

asserts that `v` is `unsigned number`.


### v = assert.is_int(v)

asserts that `v` is `int`.


### v = assert.is_int8(v)

asserts that `v` is `int8`. (from `-128` to `127`)


### v = assert.is_int16(v)

asserts that `v` is `int8`. (from `-32768` to `32767`)


### v = assert.is_int32(v)

asserts that `v` is `int8`. (from `-2147483648` to `2147483647`)

### v = assert.is_uint(v)

asserts that `v` is `uint`.


### v = assert.is_uint8(v)

asserts that `v` is `int8`. (from `0` to `255`)


### v = assert.is_uint16(v)

asserts that `v` is `int8`. (from `0` to `65535`)


### v = assert.is_uint32(v)

asserts that `v` is `int8`. (from `0` to `4294967295`)


### v = assert.empty(v)

asserts that `v` is an empty table.

### v = assert.not_empty(v)

asserts that `v` is not an empty table.


### v = assert.equal(v, expected)

asserts that `v` is equal to `expected`.


### v = assert.not_equal(v, expected)

asserts that `v` is not equal to `expected`.


### v = assert.rawequal(v, expected)

asserts that `v` is rawequal to `expected`.

### v = assert.not_rawequal(v, expected)

asserts that `v` is not rawequal to `expected`.


### v = assert.greater(v, x)

asserts that `v` is greater than `x`.


### v = assert.greater_or_equal(v, x)

asserts that `v` is greater than or equal to `x`.


### v = assert.less(v, x)

asserts that `v` is less than `x`.

### v = assert.less_or_equal(v, x)

asserts that `v` is less than or equal to `x`.


### s = assert.match(s, pattern, plain, init)

asserts that the lua `pattern` will match the string in `s`.  
the arguments are the same as for the `string.find` function.

### s = assert.not_match(s, pattern, plain, init)

asserts that the lua `pattern` will not match the string in `s`.  


### s = assert.re_match(s, pattern, flags, offset)

asserts that the regular expression `pattern` will match the string in `s`.
the arguments are the same as for the [regexp.test](https://github.com/mah0x211/lua-regex#ok-err--regextest-sbj-pattern--flgs--offset-) function.

### s = assert.re_match(s, pattern, flags, offset)

asserts that the regular expression `pattern` will not match the string in `s`.
