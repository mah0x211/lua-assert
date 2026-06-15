pcall(require, 'luacov')
local assert = assert
local pcall = pcall
local format = string.format
local lightuserdata = require('assert.lightuserdata')

local function test_lightuserdata()
    -- module returns a userdata value (lightuserdata)
    assert(type(lightuserdata) == 'userdata',
           format('expected userdata, got %s', type(lightuserdata)))

    -- the same value is returned across requires within one Lua state
    local again = require('assert.lightuserdata')
    assert(rawequal(lightuserdata, again),
           'lightuserdata should be stable across requires')
end

local fails = {}
local passed = 0
for k, fn in pairs({
    test_lightuserdata = test_lightuserdata,
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
