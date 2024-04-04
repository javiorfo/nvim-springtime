local popcorn = require 'popcorn'
local core = require 'springtime.core'
local cmp = require 'cmp'
local M = {}

local is_libraries_downloaded, libraries = pcall(require, 'springtime.libraries')
local source = {}

if is_libraries_downloaded then
    source.new = function()
        return setmetatable({}, { __index = source })
    end

    source.complete = function(_, _, callback)
        if vim.fn.line('.') >= 36 then
            callback { items = libraries }
        else
            callback { items = {} }
        end
    end
    cmp.register_source('spring_boot_libraries', source.new())
end


function M.open()
    local opts = {
        width = 50,
        height = 40,
        title = { "Springtime", "Boolean" },
        footer = { "Press Enter to proceed or ESC to close", "Comment" },
        content = core.create_content(),
        do_after = function()
            local line = vim.fn.getline(1) .. " (press space to select)"
            vim.fn.setline(1, line)
            vim.cmd(string.format("syn match springtimeSelect '%s' | hi link springtimeSelect %s", "(press space to select)", "Comment"))

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                pattern = { "<buffer>" },
                callback = function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] < 30 and pos[2] >= 0 then
                        vim.cmd [[setl noma]]
                        vim.api.nvim_win_set_cursor(0, { pos[1], 0 })
                    else
                        vim.cmd [[setl ma]]
                    end
                end
            })

            if is_libraries_downloaded then
                cmp.setup.buffer {
                    sources = {
                        { name = 'spring_boot_libraries' }
                    },
                    formatting = {
                        format = function(_, vim_item)
                            vim_item.kind = " "
                            return vim_item
                        end
                    }
                }
            end

            vim.api.nvim_buf_set_keymap(0, 'n', '<Space>', '<cmd>lua require("springtime.core").space_key_event()<CR>', { noremap = true, silent = true })
        end
    }

    popcorn:new(opts):pop()
end

return M
