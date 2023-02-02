-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.table_length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function M.unpack(tab, start, stop)
    if not start then start = 1 end
    if not stop then stop = #tab end
    if start == stop then
        return tab[start]
    else
        return tab[start], unpack(tab, start + 1, stop)
    end
end

return M
