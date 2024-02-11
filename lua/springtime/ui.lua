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
                    if pos[1] == 2 and pos[2] < 10 then
                        vim.api.nvim_win_set_cursor(0, { 2, 15 })
                    end
              end
            })

--[[             local library_list_a = function()
                vim.cmd("setlocal completeopt+=noinsert")
                vim.fn.complete(vim.fn.col('.'), { "activemq", "actuator", "amqp", "artemis", "azure-active-directory",
                "azure-cosmos-db", "azure-keyvault", "azure-storage", "azure-support", "batch", "cache", "camel", "cloud-bus", "cloud-config-client", "cloud-config-server", "cloud-contract-stub-runner", "cloud-contract-verifier", "cloud-eureka", "cloud-eureka-server", "cloud-feign", "cloud-function", "cloud-gateway", "cloud-gateway-reactive", "cloud-gcp", "cloud-gcp-pubsub", "cloud-gcp-storage", "cloud-loadbalancer", "cloud-resilience4j", "cloud-starter", "cloud-starter-consul-config"})
            end

            local library_list_c = function()
                vim.fn.complete(vim.fn.col('.'), { "cache", "camel", "cloud-bus", "cloud-config-client", "cloud-config-server"})
                return " "
            end

            vim.keymap.set('i', '<Tab>', library_list_a, { noremap = true, silent = true, buffer = 0 }) ]]
--             vim.keymap.set('i', 'c', library_list_c, { noremap = true, silent = true, buffer = 0 })

            cmp.setup.buffer {
                sources = { { name = 'spring_boot_libraries' } }
            }

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
