-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

-- TODO MODULE UNDER CONSTRUCTION

local M = {}

local function build_title(title)

end

function M:new(opts)
    local table = {}
    self.__index = self
    table = opts
    setmetatable(table, self)
    return table
end

function M:pop()
    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]

    local border = {"─", "│", "─", "│", "┌", "┐", "┘", "└"}
    local lines = {"┌──── Hola ────┐", "│              │"}
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    local opts = {relative = 'editor',
--                  title = 'Hola',
                 width = self.width,
                 height = self.height,
                 col = (ui.width/2) - (self.width/2),
                 row = (ui.height/2) - (self.height/2),
                 style = 'minimal'
                 }
    local win = vim.api.nvim_open_win(buf, true, opts)
    local opts2 = {
        relative = 'win',
        row = opts.row + 1,
        height = opts.height - 2,
        col = opts.col + 2,
        width = opts.width - 4,
        style = 'minimal'
        }
    vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, opts2)
end

local popa = M:new({ width = 50, height = 10 })
popa:pop()

return M
