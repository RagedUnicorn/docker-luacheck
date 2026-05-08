-- Sample Lua file to demonstrate Luacheck
local function greet(name)
    print("Hello, " .. name .. "!")
    local unused_variable = 42  -- This will trigger a warning
end

-- Missing local declaration (global leak)
function calculate_sum(a, b)
    return a + b
end

-- Unused argument
local function process_data(data, options)
    print("Processing: " .. data)
    -- options is not used
end

-- Correct usage
local function main()
    greet("World")
    local result = calculate_sum(5, 3)
    print("Sum: " .. result)
    process_data("test data", {verbose = true})
end

-- Call main function
main()
