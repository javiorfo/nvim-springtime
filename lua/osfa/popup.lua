-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.pop()
    local width = 50
    local height = 10

    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]

    local opts = {relative = 'editor',
                 width = width,
                 height = height,
                 col = (ui.width/2) - (width/2),
                 row = (ui.height/2) - (height/2),
                 anchor = 'NW',
                 style = 'minimal',
                 }
    local win = vim.api.nvim_open_win(buf, 1, opts)
end

return M
