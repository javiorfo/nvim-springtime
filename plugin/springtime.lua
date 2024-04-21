if vim.g.springtime then
  return
end

vim.g.springtime = 1

vim.api.nvim_create_user_command('Springtime', 'lua require("springtime.ui").open()', {})

-- Update libraries, java_version and spring_boot
vim.api.nvim_create_user_command('SpringtimeUpdate', 'lua require("springtime.core").update()', {})

-- Build and update luafiles
vim.api.nvim_create_user_command('SpringtimeBuild', 'lua require("springtime.core").build()', {})




