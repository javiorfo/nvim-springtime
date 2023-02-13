-- ##########################################################
-- # Maintainer:  Mr. Charkuils                             #
-- # URL:         https://github.com/charkuils/nvim-xpresso #
-- ##########################################################

if vim.g.xpresso then
  return
end

vim.g.xpresso = 1

-- vim.api.nvim_create_user_command('Command', 'lua require("xpresso").some_function()', {})
-- vim.api.nvim_set_keymap('n', '<Plug>Plug', '<cmd>lua require("xpresso.core").some_function()<CR>', {})
