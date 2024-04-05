local popcorn = require 'popcorn'
local core = require 'springtime.core'
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

local function set_help(java_version_line)
    local function set(line_nr)
        local line = vim.fn.getline(line_nr) .. " (press space to select)"
        vim.fn.setline(line_nr, line)
    end

    set(1)
    set(6)
    set(11)
    set(15)
    set(java_version_line)
    vim.cmd(string.format("syn match springtimeSelect '%s' | hi link springtimeSelect %s", "(press space to select)", "Comment"))
end

function M.open()
    local opts = {
        width = 50,
        height = bottom + 3,
        title = { "Springtime", "Boolean" },
        footer = { "Press Enter to proceed or ESC to close", "Comment" },
        content = content,
        do_after = function()

            set_help(core.java_version_section)

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                pattern = { "<buffer>" },
                callback = function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] <= core.project_metadata_section and pos[2] >= 0 then
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
