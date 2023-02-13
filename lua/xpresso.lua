-- ##########################################################
-- # Maintainer:  Mr. Charkuils                             #
-- # URL:         https://github.com/charkuils/nvim-xpresso #
-- ##########################################################

local M = {}
local border = {"─", "│", "─", "│", "┌", "┐", "┘", "└"}

local function build_title(title, width)
    title = " " .. title .. "  "
    local size_length = (width - 2 - #title) / 2
    local border_title = ""

    for _ = 1, size_length do
        border_title = border_title .. border[1]
    end
    return border[5] .. border_title .. title .. border_title .. border[6]
end

local function build_side(width)
    local side = "│"
    for _ = 1, width - 2 do
        side = side .. " "
    end
    return side .. "│"
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
    local side = build_side(self.width)
    local lines = {build_title("Hemingway", self.width), side, side, side}
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    local opts = {relative = 'editor',
                 width = self.width,
                 height = self.height,
                 col = (ui.width/2) - (self.width/2),
                 row = (ui.height/2) - (self.height/2),
                 style = 'minimal',
                 focusable = false
                 }
    local win = vim.api.nvim_open_win(buf, true, opts)

    local opts2 = {
        relative = 'editor',
        row = opts.row + 1,
        height = opts.height - 2,
        col = opts.col + 2,
        width = opts.width - 4,
        style = 'minimal',
        }
    local buf2 = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf2, true, opts2)
    local hem = (string.gsub(vim.inspect({  left = "--[[ ",  right = " ]]",  single = "-- "}), "\n", ""))
    vim.api.nvim_buf_set_lines(buf2, 0, -1, true, {"Filetype: lua", hem})
    vim.cmd("au BufLeave <buffer> bd " .. buf .. " | quit")
    vim.cmd("nnoremap <buffer> <esc> <cmd>quit<cr>")
end

return M
