-- #####################################################
-- # Maintainer:  Javier Orfo                          #
-- # URL:         https://github.com/javiorfo/nvim-mug #
-- #####################################################

if vim.g.mug then
  return
end

vim.g.mug = 1

-- vim.api.nvim_create_user_command('Command', 'lua require("mug").some_function()', {})
-- vim.api.nvim_set_keymap('n', '<Plug>Plug', '<cmd>lua require("mug.core").some_function()<CR>', {})
