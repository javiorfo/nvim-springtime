-- ##############################################################
-- # Maintainer:  Javier Orfo                                   #
-- # URL:         https://github.com/systemmalt/nvim-springtime #
-- ##############################################################

if vim.g.springtime then
  return
end

vim.g.springtime = 1

-- vim.api.nvim_create_user_command('Command', 'lua require("springtime").some_function()', {})
-- vim.api.nvim_set_keymap('n', '<Plug>Plug', '<cmd>lua require("springtime.core").some_function()<CR>', {})
