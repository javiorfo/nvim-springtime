-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

return M
