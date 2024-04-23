if vim.g.springtime then
    return
end

vim.g.springtime = 1

-- Open popup
vim.api.nvim_create_user_command('Springtime', function()
    require("springtime.core").open()
end, {})

-- Update libraries, java_version and spring_boot
vim.api.nvim_create_user_command('SpringtimeUpdate', function()
    require("springtime.core").update()
end, {})

-- Build and update luafiles
vim.api.nvim_create_user_command('SpringtimeBuild', function()
    require("springtime.core").build()
end, {})

-- Show log files
vim.api.nvim_create_user_command('SpringtimeLogs', function()
    require("springtime.core").show_logs()
end, {})
