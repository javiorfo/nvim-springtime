if vim.g.springtime then
  return
end

vim.g.springtime = 1

vim.api.nvim_create_user_command('Springtime', 'lua require("springtime").open()', {})
