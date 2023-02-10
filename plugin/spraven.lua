-- ##########################################################
-- # Maintainer:  Mr. Charluils                             #
-- # URL:         https://github.com/charluils/nvim-spraven #
-- ##########################################################

if vim.g.spraven then
  return
end

vim.g.spraven = 1

-- vim.api.nvim_create_user_command('Command', 'lua require("spraven").some_function()', {})
-- vim.api.nvim_set_keymap('n', '<Plug>Plug', '<cmd>lua require("spraven.core").some_function()<CR>', {})
