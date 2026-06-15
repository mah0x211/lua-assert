pcall(require, 'luacov')
local assert = assert
local pcall = pcall
local find = string.find
local format = string.format
local torawstring = require('assert.torawstring')
local lightuserdata = require('assert.lightuserdata')

local function test_torawstring()
    -- test that convert value to raw string
    for _, v in ipairs({
        {
            arg = true,
            match = '^true$',
        },
        {
            arg = false,
            match = '^false$',
        },
        {
            arg = 1,
            match = '^1$',
        },
        {
            arg = 1.2,
            match = '^1%.2$',
        },
        {
            arg = 0 / 0,
            match = '^-*nan$',
        },
        {
            arg = math.huge,
            match = '^inf$',
        },
        {
            arg = -math.huge,
            match = '^-inf$',
        },
        {
            arg = 'foo',
            match = '^string: ',
        },
        {
            arg = {},
            match = '^table: ',
        },
        {
            arg = function()
            end,
            match = '^function: ',
        },
        {
            arg = coroutine.create(function()
            end),
            match = '^thread: ',
        },
        {
            arg = io.open('/dev/null'),
            match = '^userdata: ',
        },
        {
            arg = lightuserdata,
            match = '^userdata: ',
        },
    }) do
        local s = torawstring(v.arg)
        assert(find(s, v.match),
               format('%q does not match pattern %q', s, v.match))
    end
    assert(find(torawstring(nil), '^nil$'))

    -- test that throw error without argument
    local ok, err = pcall(function()
        torawstring()
    end)
    assert(not ok)
    assert(find(err, 'argument expected, got no argument', nil, true))
end

local fails = {}
local passed = 0
for k, fn in pairs({
    test_torawstring = test_torawstring,
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
