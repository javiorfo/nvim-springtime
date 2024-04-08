local popcorn = require 'popcorn'
local core = require 'springtime.core'
local SETTINGS = require 'springtime'.SETTINGS
local cmp = require 'cmp'
local M = {}

local content = core.create_content()
local bottom = core.project_metadata_section + 7
local is_libraries_downloaded, libraries = pcall(require, 'springtime.libraries')
local source = {}

if is_libraries_downloaded then
    source.new = function()
        return setmetatable({}, { __index = source })
    end

    source.complete = function(_, _, callback)
        if vim.fn.line('.') >= bottom then
            callback { items = libraries }
        else
            callback { items = {} }
        end
    end
    cmp.register_source('spring_boot_libraries', source.new())
end

function M.open()
    local opts = {
        width = 43,
        height = bottom + 3,
        title = { "Springtime", "Boolean" },
        footer = { "ENTER to generate or ESC to close", "Comment" },
        content = content,
        do_after = function()
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                pattern = { "<buffer>" },
                callback = function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] <= core.project_metadata_section or pos[1] == (bottom - 1) or pos[1] == (bottom - 2) then
                        vim.cmd [[setl noma]]
                        vim.api.nvim_win_set_cursor(0, { pos[1], 0 })
                    else
                        vim.cmd [[setl ma]]
                    end

                    if pos[1] > core.project_metadata_section and pos[1] < (core.project_metadata_section + 5) and pos[2] < 19 then
                        vim.api.nvim_win_set_cursor(0, { pos[1], 18 })
                    end
                end
            })

            function Disable_backspace_on_metadata_section()
                local line = vim.fn.line('.')

                if vim.fn.col('.') < 20 and line > core.project_metadata_section and line < (core.project_metadata_section + 5) then
                    return ''
                else
                    return vim.api.nvim_replace_termcodes('<bs>', true, false, true)
                end
            end
            vim.api.nvim_buf_set_keymap(0, 'i', '<bs>', 'v:lua.Disable_backspace_on_metadata_section()', { noremap = true, expr = true })

            function Nothing()
                print("nada") -- TODO change to logger
                return ''
            end
            -- Disable Visual Mode
            vim.api.nvim_buf_set_keymap(0, 'n', 'v', 'v:lua.Nothing()', { noremap = true, expr = true })
            vim.api.nvim_buf_set_keymap(0, 'n', '<C-v>', 'v:lua.Nothing()', { noremap = true, expr = true })
            vim.api.nvim_buf_set_keymap(0, 'n', 'V', 'v:lua.Nothing()', { noremap = true, expr = true })

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

            vim.api.nvim_buf_set_keymap(0, 'n', SETTINGS.actions.selection_keymap,
                '<cmd>lua require("springtime.core").selection_key_event()<CR>', { noremap = true, silent = true })
        end
    }

    popcorn:new(opts):pop()
end

return M
