-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.read_from(fn, message)
    message = message or "Empty"
    local handle = fn()

    if handle then
        local result = handle:read("*a")
        handle:close()
        if #result == 0 then return message else return result end
    end
end

return M
