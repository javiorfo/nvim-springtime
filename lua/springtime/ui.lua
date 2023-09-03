local popcorn = require'popcorn'
local springtime = require'springtime'
local M = {}

function M.open()
    local opts = {
        width = 50,
        height = 40,
        title = { "Springtime", "Boolean" },
        content = springtime.create_content(),
        do_after = function()
            vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
              pattern = { "<buffer>" },
              callback = function(ev)
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] == 2 and pos[2] < 10 then
                        vim.api.nvim_win_set_cursor(0, { 2, 15 })
                    end
              end
            })
        end
    }

    popcorn:new(opts):pop()
end

return M
