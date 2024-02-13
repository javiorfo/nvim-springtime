local popcorn = require'popcorn'
local core = require'springtime.core'
local libraries = require'springtime.libraries'
local cmp = require'cmp'
local M = {}

local source = {}

source.new = function()
    return setmetatable({}, {__index = source})
end

source.complete = function(self, params, callback)
    if vim.fn.line('.') >= 36 then
        callback { items = libraries }
    else
        callback { items = {} }
    end
end

cmp.register_source('spring_boot_libraries', source.new())

function M.open()
    local opts = {
        width = 50,
        height = 40,
        title = { "Springtime", "Boolean" },
        footer = { "Press Enter proceed or ESC to close", "Comment" },
        content = core.create_content(),
        do_after = function()
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              pattern = { "<buffer>" },
              callback = function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    print(pos[1], pos[2])
                    if pos[1] < 30 and pos[2] >= 0 then
                        vim.cmd[[setl noma]]
                        vim.api.nvim_win_set_cursor(0, { pos[1], 0 })
                    else
                        vim.cmd[[setl ma]]
                    end
              end
            })

            cmp.setup.buffer {
                sources = {
                    { name = 'spring_boot_libraries' }
                },
                formatting = {
                    format = function(_, vim_item)
                        vim_item.kind = " "
                        return vim_item
                    end
                }
            }
        end
    }

    popcorn:new(opts):pop()
end
return M
