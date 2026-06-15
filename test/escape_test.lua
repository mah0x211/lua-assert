pcall(require, 'luacov')
local assert = assert
local pcall = pcall
local format = string.format
local rep = string.rep
local escape = require('assert.escape')

local function test_escape()
    -- empty string returns empty string
    assert(escape('') == '')

    -- plain printable characters are returned as-is
    assert(escape('abc XYZ 0-9') == 'abc XYZ 0-9')

    -- each named escape character is replaced with its short form
    for src, expect in pairs({
        ['\0'] = '\\0',
        ['\a'] = '\\a',
        ['\b'] = '\\b',
        ['\t'] = '\\t',
        ['\n'] = '\\n',
        ['\v'] = '\\v',
        ['\f'] = '\\f',
        ['\r'] = '\\r',
    }) do
        assert(escape(src) == expect,
               format('expected %q got %q', expect, escape(src)))
    end

    -- control characters 0x01-0x06, 0x0e-0x1f, 0x7f use \xNN form
    for _, b in ipairs({
        0x01,
        0x06,
        0x0e,
        0x10,
        0x1f,
        0x7f,
    }) do
        local got = escape(string.char(b))
        local want = format('\\x%02x', b)
        assert(got == want,
               format('byte %02x: expected %q got %q', b, want, got))
    end

    -- backslash followed by a printable byte is kept as-is
    assert(escape('\\n') == '\\n')

    -- backslash followed by a control byte drops the backslash and
    -- escapes the control byte
    assert(escape('\\\1') == '\\x01')

    -- a string longer than the internal BUFSIZ flush threshold still
    -- round-trips through the multi-chunk concatenation path
    local long = rep('a', 8192) .. '\n' .. rep('b', 8192)
    local got = escape(long)
    assert(got == rep('a', 8192) .. '\\n' .. rep('b', 8192))
end

local fails = {}
local passed = 0
for k, fn in pairs({
    test_escape = test_escape,
}) do
    io.stdout:write(k, ' ... ')
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print('ok')
    else
        print('fail')
        print(err)
        fails[#fails + 1] = {
            name = k,
            err = err,
        }
    end
end

print(string.rep('-', 40))
if #fails == 0 then
    print(format('all %d tests passed', passed))
else
    print(format('%d tests passed', passed))
    print(format('%d tests failed', #fails))
    for _, v in ipairs(fails) do
        print('  - ' .. v.name .. ': ' .. v.err)
    end
    os.exit(1)
end
