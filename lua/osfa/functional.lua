-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.apply_by_condition(condition, fn_ok, fn_not_ok)
    if condition then fn_ok() else fn_not_ok() end
end

return M
