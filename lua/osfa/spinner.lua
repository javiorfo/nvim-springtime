-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local logger = require'osfa.logger'
local M = {}

M.DEFAULT_SPINNER = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
M.ARROW_SPINNER = { "▹▹▹▹▹", "▸▹▹▹▹", "▹▸▹▹▹", "▹▹▸▹▹", "▹▹▹▸▹", "▹▹▹▹▸" }
M.EQUALS_SPINNER = { "[    ]", "[=   ]", "[==  ]", "[=== ]", "[ ===]", "[  ==]", "[   =]", "[    ]", "[   =]", "[  ==]", "[ ===]", "[====]", "[=== ]", "[==  ]", "[=   ]" }
M.PING_PONG_SPINNER = { "( ●    )", "(  ●   )", "(   ●  )", "(    ● )", "(     ●)", "(    ● )", "(   ●  )", "(  ●   )", "( ●    )", "(●     )" }
M.POINT_SPINNER = { "∙∙∙", "●∙∙", "∙●∙", "∙∙●", "∙∙∙" }
M.PROGRESS_BAR_SPINNER = { "▰▱▱▱▱▱▱", "▰▰▱▱▱▱▱", "▰▰▰▱▱▱▱", "▰▰▰▰▱▱▱", "▰▰▰▰▰▱▱", "▰▰▰▰▰▰▱", "▰▰▰▰▰▰▰", "▰▱▱▱▱▱▱" }

function M:new(values, fn_to_stop_spinner)
    if not fn_to_stop_spinner then
        logger:new("Spinner"):error("A function is required as second parameter to stop the spinner.")
        return
    end

    local table = {}
    self.__index = self
    table.values = values
    table.fn_to_stop_spinner = fn_to_stop_spinner
    setmetatable(table, self)
    return table
end

function M:get_sleep_ms()
    return self.values.sleep_ms
end

function M:get_starting_msg()
    return self.values.starting_msg
end

function M:get_spinner()
    return self.values.spinner
end

function M:start()
    local sleep_ms = self.values.sleep_ms or 200
    local starting_msg = self.values.starting_msg or ""
    local spinner = self.values.spinner or M.DEFAULT_SPINNER
    local internal_logger = logger:new()

    local index = 1
    local is_interrupted = false
    while true do
        local _, error = pcall(function()
            internal_logger:info(starting_msg .. spinner[index])
            if index < #spinner then
                index = index + 1
            else
                index = 1
            end

            vim.cmd(string.format("sleep %dms", sleep_ms))
            vim.cmd("redraw")
        end)

        if self.fn_to_stop_spinner() or error then
            if error then is_interrupted = true end
            break
        end
    end
    return is_interrupted
end

return M
