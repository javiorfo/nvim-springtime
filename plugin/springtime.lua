if vim.g.springtime then
  return
end

vim.g.springtime = 1

vim.api.nvim_create_user_command('Springtime', 'lua require("springtime.ui").open()', {})

-- TODO update libraries, java_version and spring_boot
vim.api.nvim_create_user_command('SpringtimeUpdate', 'lua require("springtime.core").update()', {})


