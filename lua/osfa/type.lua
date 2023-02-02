-- ####################################################
-- # Maintainer:  Javier Orfo                         #
-- # URL:         https://github.com/javi-7/nvim-osfa #
-- ####################################################

local M = {}

function M.is_string(value) return type(value) == "string" end

function M.is_boolean(value) return type(value) == "boolean" end

function M.is_number(value) return type(value) == "number" end

function M.is_function(value) return type(value) == "function" end

function M.is_table(value) return type(value) == "table" end

return M
