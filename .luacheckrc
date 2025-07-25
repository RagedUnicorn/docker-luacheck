-- Example Luacheck configuration file
-- See https://luacheck.readthedocs.io/en/stable/config.html for details

return {
    -- Lua standard to use
    std = "lua53",

    -- Global variables that are allowed
    globals = {
        -- Add your project-specific globals here
        -- "love", -- For Love2D projects
        -- "vim",  -- For Neovim plugins
    },

    -- Read-only globals
    read_globals = {
        -- Common read-only globals
        -- "jit",
        -- "bit",
    },

    -- Warnings to ignore
    ignore = {
        -- "211", -- Unused local variable
        -- "212", -- Unused argument
        -- "213", -- Unused loop variable
    },

    -- Files/patterns to exclude
    exclude_files = {
        ".luacheckrc",
        "vendor/",
        "libs/",
        ".rocks/",
    },

    -- Maximum line length
    max_line_length = 120,

    -- Maximum cyclomatic complexity
    max_cyclomatic_complexity = 15,

    -- Per-file overrides
    files = {
        ["test/**/*.lua"] = {
            std = "+busted", -- Add busted testing framework globals
            ignore = {"211", "212", "213"}, -- Ignore unused warnings in tests
        },
        ["spec/**/*.lua"] = {
            std = "+busted",
            ignore = {"211", "212", "213"},
        },
    },
}
