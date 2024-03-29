require('luacov')
local assert = assert
local pcall = pcall
local find = string.find
local format = string.format
local assertex = require('assert')
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

-- test that assertex(...) is almost equivalent to assert(...)
local function test_call()
    -- test that throw error if nil
    local ok, err = pcall(function()
        assertex(nil, 'failed with nil')
    end)
    assert(not ok)
    assert(find(err, 'failed with nil', nil, true))

    -- test that throw error if false
    ok, err = pcall(function()
        assertex(false, 'failed with false')
    end)
    assert(not ok)
    assert(find(err, 'failed with false', nil, true))

    -- test that use a second arguments as an error message
    ok, err = pcall(function()
        assertex(nil, setmetatable({}, {
            __tostring = function()
                return '__tostring metamethod has been called'
            end,
        }))
    end)
    assert(not ok)
    assert(find(err, '__tostring metamethod has been called', nil, true))

    -- test that not throw error if the argument is neither nil nor false
    for _, v in ipairs({
        -1,
        0,
        1,
        true,
        {},
        coroutine.create(function()
        end),
        function()
        end,
    }) do
        ok, err = pcall(function()
            local tbl = {}
            local res = {
                assertex(v, 'foo', 1, tbl),
            }
            -- test that returns all arguments
            assert(res[1] == v and res[2] == 'foo' and res[3] == 1 and res[4] ==
                       tbl)
        end)
        assert(ok)
        assert(not err)
    end
end

local function test_newindex()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.foo = 'bar'
    end)
    assert(not ok)
    assert(find(err, '<"foo"> = <"bar">', nil, true))
end

local function test_throws()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.throws(function(a, b, c)
            assert(a == 'foo')
            assert(b == 1)
            assert(c == true)
        end, 'foo', 1, true)
    end)
    assert(not ok)
    assert(find(err, 'should throw an error', nil, true), err)

    -- test that throw error if argument is not function
    ok, err = pcall(function()
        assertex.throws(1)
    end)
    assert(not ok)
    assert(find(err, '#1 (function expected,', nil, true), err)

    -- test that not throw error
    ok, err = pcall(function()
        assertex.throws(function()
            error('fail')
        end)
    end)
    assert(ok)
    assert(not err)
end

local function test_not_throws()
    -- test that not throw error
    local ok, err = pcall(function()
        return assertex.not_throws(function(a)
            assert(a == 'foo')
            return 'hello'
        end, 'foo')
    end)
    assert(ok)
    assert(err == 'hello')

    -- test that throw error if argument is not function
    ok, err = pcall(function()
        assertex.not_throws(1)
    end)
    assert(not ok)
    assert(find(err, '#1 (function expected,', nil, true), err)

    -- test that throw error
    ok, err = pcall(function()
        assertex.not_throws(function()
            error('fail')
        end)
    end)
    assert(ok == false)
    assert(find(err, 'should not throw an error', nil, true), err)
end

local function test_is()
    local str = 'foo'
    local num = 1
    local fnum = 1.3
    local nan = 0 / 0
    local inf = math.huge
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)

    -- test that throw error
    for k, t in pairs({
        ['boolean'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
        },
        ['true'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            false,
        },
        ['false'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
        },
        ['nil'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['none'] = {
            str,
            num,
            inf,
            tbl,
            f,
            co,
            true,
        },
        ['table'] = {
            str,
            num,
            nan,
            inf,
            f,
            co,
            true,
            false,
        },
        ['function'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            co,
            true,
            false,
        },
        ['thread'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            true,
            false,
        },
        -- ['userdata'] = {},
        ['string'] = {
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['nan'] = {
            str,
            num,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['number'] = {
            str,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['finite'] = {
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['unsigned'] = {
            -1,
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int'] = {
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int8'] = {
            128,
            -129,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int16'] = {
            32768,
            -32769,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int32'] = {
            2147483648,
            -2147483649,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint'] = {
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint8'] = {
            256,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint16'] = {
            65536,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint32'] = {
            4294967296,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
    }) do
        for _, v in ipairs(t) do
            local ok, err = pcall(function()
                -- print('is_' .. k, v)
                assertex['is_' .. k](v)
            end)
            assert(not ok)
            assert(find(err, 'is not ' .. k, nil, true), err)
        end
    end

    -- test that not throw error
    for k, t in pairs({
        ['boolean'] = {
            true,
            false,
        },
        ['true'] = {
            true,
        },
        ['false'] = {
            false,
        },
        ['none'] = {
            false,
            0,
            '',
            nan,
        },
        ['table'] = {
            tbl,
        },
        ['function'] = {
            f,
        },
        ['thread'] = {
            co,
        },
        -- ['userdata'] = {},
        ['string'] = {
            str,
        },
        ['nan'] = {
            nan,
        },
        ['number'] = {
            num,
            fnum,
            nan,
            inf,
        },
        ['finite'] = {
            num,
        },
        ['unsigned'] = {
            0,
            1,
        },
        ['int'] = {
            -1,
            0,
            1,
        },
        ['int8'] = {
            -128,
            0,
            127,
        },
        ['int16'] = {
            -32768,
            32767,
        },
        ['int32'] = {
            -2147483648,
            2147483647,
        },
        ['uint'] = {
            0,
            1,
        },
        ['uint8'] = {
            0,
            255,
        },
        ['uint16'] = {
            0,
            65535,
        },
        ['uint32'] = {
            0,
            4294967295,
        },
    }) do
        for _, v in ipairs(t) do
            local ok, err = pcall(function()
                assertex['is_' .. k](v)
            end)
            assert(ok)
            assert(not err)
        end
    end

    -- testing the nil value
    local ok, err = pcall(function()
        assertex.is_nil(nil)
        assertex.is_none(nil)
    end)
    assert(ok)
    assert(not err)
end

local function test_not()
    local str = 'foo'
    local num = 1
    local fnum = 1.3
    local nan = 0 / 0
    local inf = math.huge
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)

    -- test that not throw error
    for k, t in pairs({
        ['boolean'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
        },
        ['true'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            false,
        },
        ['false'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
        },
        ['nil'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['none'] = {
            str,
            num,
            inf,
            tbl,
            f,
            co,
            true,
        },
        ['table'] = {
            str,
            num,
            nan,
            inf,
            f,
            co,
            true,
            false,
        },
        ['function'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            co,
            true,
            false,
        },
        ['thread'] = {
            str,
            num,
            nan,
            inf,
            tbl,
            f,
            true,
            false,
        },
        -- ['userdata'] = {},
        ['string'] = {
            num,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['nan'] = {
            str,
            num,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['number'] = {
            str,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['finite'] = {
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['unsigned'] = {
            -1,
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int'] = {
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int8'] = {
            128,
            -129,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int16'] = {
            32768,
            -32769,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['int32'] = {
            2147483648,
            -2147483649,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint'] = {
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            str,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint8'] = {
            256,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint16'] = {
            65536,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
        ['uint32'] = {
            4294967296,
            -1,
            str,
            fnum,
            nan,
            inf,
            tbl,
            f,
            co,
            true,
            false,
        },
    }) do
        for _, v in ipairs(t) do
            local ok, err = pcall(function()
                -- print('not_' .. k, v)
                assertex['not_' .. k](v)
            end)
            assert(ok)
            assert(not err)
        end
    end

    -- test that throw error
    for k, t in pairs({
        ['boolean'] = {
            true,
            false,
        },
        ['true'] = {
            true,
        },
        ['false'] = {
            false,
        },
        ['none'] = {
            false,
            0,
            '',
            nan,
        },
        ['table'] = {
            tbl,
        },
        ['function'] = {
            f,
        },
        ['thread'] = {
            co,
        },
        -- ['userdata'] = {},
        ['string'] = {
            str,
        },
        ['nan'] = {
            nan,
        },
        ['number'] = {
            num,
            fnum,
            nan,
            inf,
        },
        ['finite'] = {
            num,
        },
        ['unsigned'] = {
            0,
            1,
        },
        ['int'] = {
            -1,
            0,
            1,
        },
        ['int8'] = {
            -128,
            0,
            127,
        },
        ['int16'] = {
            -32768,
            32767,
        },
        ['int32'] = {
            -2147483648,
            2147483647,
        },
        ['uint'] = {
            0,
            1,
        },
        ['uint8'] = {
            0,
            255,
        },
        ['uint16'] = {
            0,
            65535,
        },
        ['uint32'] = {
            0,
            4294967295,
        },
    }) do
        for _, v in ipairs(t) do
            local ok, err = pcall(function()
                assertex['not_' .. k](v)
            end)
            assert(ok == false)
            assert(find(err, 'is ' .. k, nil, true), err)
        end
    end

    -- testing the nil value
    local ok, err = pcall(function()
        assertex.is_nil(nil)
        assertex.is_none(nil)
    end)
    assert(ok)
    assert(not err)
end

local function test_empty()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.empty({
            1,
        })
    end)
    assert(not ok)
    assert(find(err, 'is not empty', nil, true))

    -- test that throw error if argument is not table
    for _, v in ipairs({
        1,
        true,
        coroutine.create(function()
        end),
        function()
        end,
    }) do
        ok, err = pcall(function()
            assertex.empty(v)
        end)
        assert(not ok)
        assert(find(err, format('table expected, got %s', type(v)), nil, true))
    end

    -- test that not throw error
    ok, err = pcall(function()
        assertex.empty({})
    end)
    assert(ok)
    assert(not err)
end

local function test_not_empty()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.not_empty({})
    end)
    assert(not ok)
    assert(find(err, 'is empty', nil, true))

    -- test that throw error if argument is not table
    for _, v in ipairs({
        1,
        true,
        coroutine.create(function()
        end),
        function()
        end,
    }) do
        ok, err = pcall(function()
            assertex.not_empty(v)
        end)
        assert(not ok)
        assert(find(err, format('table expected, got %s', type(v)), nil, true))
    end

    -- test that not throw error if argument is not empty
    ok, err = pcall(function()
        assertex.not_empty({
            1,
        })
    end)
    assert(ok)
    assert(not err)
end

local function test_equal()
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)
    local nan = 0 / 0

    -- test that throw error
    for k, v in pairs({
        [1] = 2,
        [true] = false,
        [tbl] = {
            1,
            2,
            3,
        },
        [f] = function()
        end,
        [co] = coroutine.create(f),
    }) do
        local ok, err = pcall(function()
            assertex.equal(k, v)
        end)
        assert(not ok)
        assert(find(err, 'should be equal', nil, true))
    end

    -- test that throw error if arguments are not of the same type
    for k, v in pairs({
        [1] = false,
        [true] = tbl,
        [tbl] = f,
        [f] = co,
        [co] = nan,
    }) do
        local ok, err = pcall(function()
            assertex.equal(k, v)
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> == #2 <%s>', type(k), type(v)), nil,
                    true))
    end

    -- test that not throw error
    for _, v in ipairs({
        1,
        true,
        tbl,
        f,
        co,
        nan,
    }) do
        local ok, err = pcall(function()
            assertex.equal(v, v)
        end)
        assert(ok)
        assert(not err)
    end
end

local function test_not_equal()
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)
    local nan = 0 / 0

    -- test that throw error
    for _, v in pairs({
        1,
        true,
        tbl,
        f,
        co,
        nan,
    }) do
        local ok, err = pcall(function()
            assertex.not_equal(v, v)
        end)
        assert(not ok)
        assert(find(err, 'should not be equal', nil, true))
    end

    -- test that throw error if arguments are not of the same type
    for k, v in pairs({
        [1] = false,
        [true] = tbl,
        [tbl] = f,
        [f] = co,
        [co] = nan,
    }) do
        local ok, err = pcall(function()
            assertex.not_equal(k, v)
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> == #2 <%s>', type(k), type(v)), nil,
                    true))
    end

    -- test that not throw error
    for k, v in pairs({
        [1] = 2,
        [true] = false,
        [tbl] = {
            1,
        },
        [f] = function()
        end,
        [co] = coroutine.create(f),
    }) do
        local ok, err = pcall(function()
            assertex.not_equal(k, v)
        end)
        assert(ok)
        assert(not err)
    end
end

local function test_rawequal()
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)
    local nan = 0 / 0

    -- test that throw error
    for k, v in pairs({
        [1] = 2,
        [true] = false,
        [tbl] = {
            1,
            2,
            3,
        },
        [f] = function()
        end,
        [co] = coroutine.create(f),
    }) do
        local ok, err = pcall(function()
            assertex.rawequal(k, v)
        end)
        assert(not ok)
        assert(find(err, 'should be raw equal', nil, true))
    end

    -- test that not throw error
    for _, v in ipairs({
        1,
        true,
        tbl,
        f,
        co,
        nan,
    }) do
        local ok, err = pcall(function()
            assertex.rawequal(v, v)
        end)
        assert(ok)
        assert(not err)
    end

    -- test that throw error if arguments are not of the same type
    local ok, err = pcall(function()
        assertex.rawequal(1, false)
    end)
    assert(not ok)
    assert(find(err, 'invalid comparison'))
end

local function test_not_rawequal()
    local tbl = {}
    local f = function()
    end
    local co = coroutine.create(f)
    local nan = 0 / 0

    -- test that throw error
    for _, v in pairs({
        1,
        true,
        tbl,
        f,
        co,
        nan,
    }) do
        local ok, err = pcall(function()
            assertex.not_rawequal(v, v)
        end)
        assert(not ok)
        assert(find(err, 'should not be raw equal', nil, true))
    end

    -- test that not throw error
    for k, v in pairs({
        [1] = 2,
        [true] = false,
        [tbl] = {
            1,
        },
        [f] = function()
        end,
        [co] = coroutine.create(f),
    }) do
        local ok, err = pcall(function()
            assertex.not_rawequal(k, v)
        end)
        assert(ok)
        assert(not err)
    end

    -- test that throw error if arguments are not of the same type
    local ok, err = pcall(function()
        assertex.not_rawequal(1, false)
    end)
    assert(not ok)
    assert(find(err, 'invalid comparison'))
end

local function test_greater()
    local nan = 0 / 0

    -- test that throw error
    local ok, err = pcall(function()
        assertex.greater(1, 2)
    end)
    assert(not ok)
    assert(find(err, format('<%s> is not greater than <%s>', 1, 2), nil, true))

    -- test that throw error if argument is not finite number
    for _, v in ipairs({
        {
            nan,
            1,
        },
        {
            1,
            nan,
        },
    }) do
        ok, err = pcall(function()
            assertex.greater(v[1], v[2])
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> > #2 <%s>', v[1], v[2]), nil, true),
               err)
    end

    -- test that not throw error
    ok, err = pcall(function()
        assertex.greater(1, -1)
    end)
    assert(ok)
    assert(not err)
end

local function test_greater_or_equal()
    local nan = 0 / 0

    -- test that throw error
    local ok, err = pcall(function()
        assertex.greater_or_equal(1, 2)
    end)
    assert(not ok)
    assert(find(err, format('<%s> is not greater than or equal to <%s>', 1, 2),
                nil, true))

    -- test that throw error if argument is not finite number
    for _, v in ipairs({
        {
            nan,
            1,
        },
        {
            1,
            nan,
        },
    }) do
        ok, err = pcall(function()
            assertex.greater_or_equal(v[1], v[2])
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> >= #2 <%s>', v[1], v[2]), nil, true),
               err)
    end

    -- test that not throw error
    for _, v in ipairs({
        {
            1,
            -1,
        },
        {
            1,
            1,
        },
    }) do
        ok, err = pcall(function()
            assertex.greater_or_equal(v[1], v[2])
        end)
        assert(ok)
        assert(not err)
    end
end

local function test_less()
    local nan = 0 / 0

    -- test that throw error
    local ok, err = pcall(function()
        assertex.less(2, 1)
    end)
    assert(not ok)
    assert(find(err, format('<%s> is not less than <%s>', 2, 1), nil, true))

    -- test that throw error if argument is not finite number
    for _, v in ipairs({
        {
            nan,
            1,
        },
        {
            1,
            nan,
        },
    }) do
        ok, err = pcall(function()
            assertex.less(v[1], v[2])
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> < #2 <%s>', v[1], v[2]), nil, true),
               err)
    end

    -- test that not throw error
    ok, err = pcall(function()
        assertex.less(-1, 1)
    end)
    assert(ok)
    assert(not err)
end

local function test_less_or_equal()
    local nan = 0 / 0

    -- test that throw error
    local ok, err = pcall(function()
        assertex.less_or_equal(2, 1)
    end)
    assert(not ok)
    assert(find(err, format('<%s> is not less than or equal to <%s>', 2, 1),
                nil, true))

    -- test that throw error if argument is not finite number
    for _, v in ipairs({
        {
            nan,
            1,
        },
        {
            1,
            nan,
        },
    }) do
        ok, err = pcall(function()
            assertex.less_or_equal(v[1], v[2])
        end)
        assert(not ok)
        assert(find(err, format('#1 <%s> <= #2 <%s>', v[1], v[2]), nil, true),
               err)
    end

    -- test that not throw error
    for _, v in ipairs({
        {
            1,
            2,
        },
        {
            1,
            1,
        },
    }) do
        ok, err = pcall(function()
            assertex.less_or_equal(v[1], v[2])
        end)
        assert(ok)
        assert(not err)
    end
end

local function test_match()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.match('foo/bar/baz', 'foo,bar')
    end)
    assert(not ok)
    assert(find(err, 'should match', nil, true), err)

    -- test that throw error if subject is not string
    ok, err = pcall(function()
        assertex.match(1)
    end)
    assert(not ok)
    assert(find(err, format('#1 (string expected,'), nil, true), err)

    -- test that throw error if pattern is not string
    ok, err = pcall(function()
        assertex.match('foo/bar/baz', 1)
    end)
    assert(not ok)
    assert(find(err, format('#2 (string expected,'), nil, true), err)

    -- test that throw error if plain is not boolean or nil
    ok, err = pcall(function()
        assertex.match('foo/bar/baz', 'foo', 1)
    end)
    assert(not ok)
    assert(find(err, format('#3 (boolean or nil expected,'), nil, true), err)

    -- test that throw error if offset is not integer or nil
    ok, err = pcall(function()
        assertex.match('foo/bar/baz', 'foo', nil, 1.1)
    end)
    assert(not ok)
    assert(find(err, format('#4 (integer or nil expected,'), nil, true), err)

    -- test that not throw error
    ok, err = pcall(function()
        local s = assertex.match('foo/bar/baz', 'foo/bar')
        assert(s == 'foo/bar/baz')
    end)
    assert(ok)
    assert(not err)
end

local function test_not_match()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.not_match('foo/bar/baz', 'foo/bar')
    end)
    assert(not ok)
    assert(find(err, 'should not match', nil, true), err)

    -- test that throw error if subject is not string
    ok, err = pcall(function()
        assertex.not_match(1)
    end)
    assert(not ok)
    assert(find(err, format('#1 (string expected,'), nil, true), err)

    -- test that throw error if pattern is not string
    ok, err = pcall(function()
        assertex.not_match('foo/bar/baz', 1)
    end)
    assert(not ok)
    assert(find(err, format('#2 (string expected,'), nil, true), err)

    -- test that throw error if plain is not boolean or nil
    ok, err = pcall(function()
        assertex.not_match('foo/bar/baz', 'foo', 1)
    end)
    assert(not ok)
    assert(find(err, format('#3 (boolean or nil expected,'), nil, true), err)

    -- test that throw error if offset is not integer or nil
    ok, err = pcall(function()
        assertex.not_match('foo/bar/baz', 'foo', nil, 1.1)
    end)
    assert(not ok)
    assert(find(err, format('#4 (integer or nil expected,'), nil, true), err)

    -- test that not throw error
    ok, err = pcall(function()
        local s = assertex.not_match('foo/bar/baz', 'foo,bar')
        assert(s == 'foo/bar/baz')
    end)
    assert(ok)
    assert(not err)
end

local function test_re_match()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.re_match('foo/bar/baz', 'foo,bar')
    end)
    assert(not ok)
    assert(find(err, 'should match', nil, true), err)

    -- test that throw error if subject is not string
    ok, err = pcall(function()
        assertex.re_match(1)
    end)
    assert(not ok)
    assert(find(err, format('#1 (string expected,'), nil, true), err)

    -- test that throw error if pattern is not string
    ok, err = pcall(function()
        assertex.re_match('foo/bar/baz', 1)
    end)
    assert(not ok)
    assert(find(err, format('#2 (string expected,'), nil, true), err)

    -- test that throw error if plain is not boolean or nil
    ok, err = pcall(function()
        assertex.re_match('foo/bar/baz', 'foo', 1)
    end)
    assert(not ok)
    assert(find(err, format('#3 (string or nil expected,'), nil, true), err)

    -- test that throw error if offset is not integer or nil
    ok, err = pcall(function()
        assertex.re_match('foo/bar/baz', 'foo', nil, 1.1)
    end)
    assert(not ok)
    assert(find(err, format('#4 (integer or nil expected,'), nil, true), err)

    -- test that not throw error
    ok, err = pcall(function()
        local s = assertex.re_match('foo/bar/baz', 'foo/*[/].+az')
        assert(s == 'foo/bar/baz')
    end)
    assert(ok)
    assert(not err)
end

local function test_not_re_match()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.not_re_match('foo/bar/baz', 'foo/bar')
    end)
    assert(not ok)
    assert(find(err, 'should not match', nil, true), err)

    -- test that throw error if subject is not string
    ok, err = pcall(function()
        assertex.not_re_match(1)
    end)
    assert(not ok)
    assert(find(err, format('#1 (string expected,'), nil, true), err)

    -- test that throw error if pattern is not string
    ok, err = pcall(function()
        assertex.not_re_match('foo/bar/baz', 1)
    end)
    assert(not ok)
    assert(find(err, format('#2 (string expected,'), nil, true), err)

    -- test that throw error if plain is not boolean or nil
    ok, err = pcall(function()
        assertex.not_re_match('foo/bar/baz', 'foo', 1)
    end)
    assert(not ok)
    assert(find(err, format('#3 (string or nil expected,'), nil, true), err)

    -- test that throw error if offset is not integer or nil
    ok, err = pcall(function()
        assertex.not_re_match('foo/bar/baz', 'foo', nil, 1.1)
    end)
    assert(not ok)
    assert(find(err, format('#4 (integer or nil expected,'), nil, true), err)

    -- test that not throw error
    ok, err = pcall(function()
        local s = assertex.not_re_match('foo/bar/baz', 'boo/*[/].+az')
        assert(s == 'foo/bar/baz')
    end)
    assert(ok)
    assert(not err)
end

local function test_contains()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.contains({
            foo = 'bar',
        }, {
            hello = 'world',
        })
    end)
    assert(not ok)
    assert(find(err, 'is not contained', nil, true))

    -- test that not throw error
    for _, v in ipairs({
        {
            act = 'hello',
            exp = 'hello',
        },
        {
            act = 1,
            exp = 1,
        },
        {
            act = true,
            exp = true,
        },
        {
            act = {
                foo = {
                    bar = {
                        baz = {
                            qux = 'quux',
                        },
                    },
                },
                hello = {
                    world = 'contained',
                },
            },
            exp = 'contained',
        },
        {
            act = {
                foo = {
                    bar = {
                        baz = {
                            qux = 'quux',
                            tbl = {},
                        },
                        qux = 'quux',
                    },
                },
                hello = {
                    world = 'contained',
                },
            },
            exp = {
                foo = {
                    ['bar.baz'] = {
                        qux = 'quux',
                        tbl = {},
                    },
                },
                ['hello.world'] = 'contained',
            },
        },
    }) do
        ok, err = pcall(function()
            assertex.contains(v.act, v.exp)
        end)
        assert(ok, err)
        assert(not err, err)
    end

    -- test that throw error if attempt to compare arguments of different types
    ok, err = pcall(function()
        assertex.contains('foo', {
            'foo',
        })
    end)
    assert(not ok)
    assert(find(err, 'invalid argument #2 (string expected, got table)', nil,
                true), err)

    -- test that throw error if different type arguments comparison
    ok, err = pcall(function()
        assertex.contains(true, {
            'foo',
        })
    end)
    assert(not ok)
    assert(find(err, 'invalid comparison', nil, true), err)
end

local function test_not_contains()
    -- test that throw error
    local ok, err = pcall(function()
        assertex.not_contains({
            foo = 'bar',
        }, {
            foo = 'bar',
        })
    end)
    assert(not ok)
    assert(find(err, 'is contained', nil, true))

    -- test that not throw error
    ok, err = pcall(function()
        assertex.not_contains({
            foo = {
                bar = {
                    baz = {
                        qux = 'quux',
                    },
                },
            },
            hello = {
                world = 'contained',
            },
        }, {
            foo = {
                bar = {
                    baz = {
                        qux = 'quu',
                    },
                },
            },
            hello = {
                world = 'contained',
            },
        })
    end)
    assert(ok, err)
    assert(not err, err)
end

local fails = {}
local passed = 0
for k, fn in pairs({
    test_torawstring = test_torawstring,
    test_call = test_call,
    test_newindex = test_newindex,
    test_throws = test_throws,
    test_not_throws = test_not_throws,
    test_is = test_is,
    test_not = test_not,
    test_empty = test_empty,
    test_not_empty = test_not_empty,
    test_equal = test_equal,
    test_not_equal = test_not_equal,
    test_rawequal = test_rawequal,
    test_not_rawequal = test_not_rawequal,
    test_greater = test_greater,
    test_greater_or_equal = test_greater_or_equal,
    test_less = test_less,
    test_less_or_equal = test_less_or_equal,
    test_match = test_match,
    test_not_match = test_not_match,
    test_re_match = test_re_match,
    test_not_re_match = test_not_re_match,
    test_contains = test_contains,
    test_not_contains = test_not_contains,
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
