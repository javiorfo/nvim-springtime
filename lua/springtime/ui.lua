local popcorn = require'popcorn'
local core = require'springtime.core'
local M = {}

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
                    if pos[1] == 2 and pos[2] < 10 then
                        vim.api.nvim_win_set_cursor(0, { 2, 15 })
                    end
              end
            })

            local library_list_a = function()
                vim.fn.complete(vim.fn.col('.'), { "activemq", "actuator", "amqp", "artemis", "azure-active-directory",
                "azure-cosmos-db", "azure-keyvault", "azure-storage", "azure-support"})
            end

            local library_list_c = function()
                vim.fn.complete(vim.fn.col('.'), { "cache", "camel", "cloud-bus", "cloud-config-client", "cloud-config-server"})
                return " "
            end

            vim.keymap.set('i', 'a', library_list_a, { noremap = true, silent = true, buffer = 0 })
            vim.keymap.set('i', 'c', library_list_c, { noremap = true, silent = true, buffer = 0 })

--[[             vim.api.nvim_create_autocmd({"InsertEnter"}, {
              pattern = { "<buffer>" },
              callback = function()
                    local pos = vim.api.nvim_win_get_cursor(0)
                    if pos[1] == 2 and pos[2] < 10 then
                        vim.api.nvim_win_set_cursor(0, { 2, 15 })
                    end
              end
            }) ]]
        end
    }

    popcorn:new(opts):pop()
end
return M
