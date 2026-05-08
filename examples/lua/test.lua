-- Test file for luacheck
local function greet(name)
    print("Hello, " .. name)
end

-- Call the function
greet("World")

-- Unused variable to trigger a warning
local unused_var = 42
