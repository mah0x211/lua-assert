-- Run every test/*_test.lua file in this directory and exit non-zero if
-- any of them fail. Each file is executed in a fresh chunk via dofile so
-- that test files share no state.
local format = string.format

local files = {}
local p = io.popen('ls test/*_test.lua 2>/dev/null')
if p then
    for line in p:lines() do
        files[#files + 1] = line
    end
    p:close()
end
table.sort(files)

local fails = {}
for _, path in ipairs(files) do
    print(format('# %s', path))
    local ok, err = pcall(dofile, path)
    if not ok then
        fails[#fails + 1] = {
            path = path,
            err = err,
        }
    end
end

if #fails > 0 then
    print(format('%d test file(s) failed', #fails))
    for _, v in ipairs(fails) do
        print('  - ' .. v.path .. ': ' .. tostring(v.err))
    end
    os.exit(1)
end
