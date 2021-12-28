# lua-assertex

[![test](https://github.com/mah0x211/lua-assertex/actions/workflows/test.yml/badge.svg)](https://github.com/mah0x211/lua-assertex/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/mah0x211/lua-assertex/badge.svg?branch=master)](https://coveralls.io/github/mah0x211/lua-assertex?branch=master)

simple assertion module for lua.

## Installation

```sh
luarocks install assertex
```

## Functions

### assertex (v [, message])

issues an error when the value of its argument `v` is `false` (i.e., `nil` or `false`); otherwise, returns all its arguments. `message` is an error message; when absent, it defaults to `"assertion failed!"`.


### err = assertex.throws(f, ...)

asserts that the function `f` to throws an error.

### v = assertex.is_boolean(v)

asserts that `v` is `boolean`.


### v = assertex.is_true(v)

asserts that `v` is `true`.


### v = assertex.is_false(v)

asserts that `v` is `false`.


### v = assertex.is_nil(v)

asserts that `v` is `nil`.


### v = assertex.is_none(v)

asserts that `v` is `none` value.  
values of `none` are `nil`, `false`, `0`, `''` and `nan`.


### v = assertex.is_nan(v)

asserts that `v` is `nan`.

### v = assertex.is_finite(v)

asserts that `v` is `finite number`.

### v = assertex.is_unsigned(v)

asserts that `v` is `unsigned number`.


### v = assertex.is_int(v)

asserts that `v` is `int`.


### v = assertex.is_int8(v)

asserts that `v` is `int8`. (from `-128` to `127`)


### v = assertex.is_int16(v)

asserts that `v` is `int8`. (from `-32768` to `32767`)


### v = assertex.is_int32(v)

asserts that `v` is `int8`. (from `-2147483648` to `2147483647`)

### v = assertex.is_uint(v)

asserts that `v` is `uint`.


### v = assertex.is_uint8(v)

asserts that `v` is `int8`. (from `0` to `255`)


### v = assertex.is_uint16(v)

asserts that `v` is `int8`. (from `0` to `65535`)


### v = assertex.is_uint32(v)

asserts that `v` is `int8`. (from `0` to `4294967295`)


### v = assertex.empty(v)

asserts that `v` is an empty table.

### v = assertex.not_empty(v)

asserts that `v` is not an empty table.


### v = assertex.equal(v, expected)

asserts that `v` is equal to `expected`.


### v = assertex.not_equal(v, expected)

asserts that `v` is not equal to `expected`.


### v = assertex.rawequal(v, expected)

asserts that `v` is rawequal to `expected`.

### v = assertex.not_rawequal(v, expected)

asserts that `v` is not rawequal to `expected`.


### v = assertex.greater(v, x)

asserts that `v` is greater than `x`.


### v = assertex.greater_or_equal(v, x)

asserts that `v` is greater than or equal to `x`.


### v = assertex.less(v, x)

asserts that `v` is less than `x`.

### v = assertex.less_or_equal(v, x)

asserts that `v` is less than or equal to `x`.


### s = assertex.match(s, pattern, plain, init)

asserts that the lua `pattern` will match the string in `s`.  
the arguments are the same as for the `string.find` function.

### s = assertex.not_match(s, pattern, plain, init)

asserts that the lua `pattern` will not match the string in `s`.  


### s = assertex.re_match(s, pattern, flags, offset)

asserts that the regular expression `pattern` will match the string in `s`.
the arguments are the same as for the [regexp.test](https://github.com/mah0x211/lua-regex#ok-err--regextest-sbj-pattern--flgs--offset-) function.

### s = assertex.re_match(s, pattern, flags, offset)

asserts that the regular expression `pattern` will not match the string in `s`.
