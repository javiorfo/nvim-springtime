local logger = require 'springtime.logger'

local M = {}

M.logger = logger:new()
M.spring_url = "https://start.spring.io"
M.springtime_log_file = vim.fn.stdpath('log') .. "/springtime.log"
M.debug_header = string.format("[DEBUG][%s]:", os.date("%m/%d/%Y %H:%M:%S"))
M.lua_springtime_path = debug.getinfo(1).source:match("@?(.*/)")

function M.check_if_file_exists(file, path)
    local checked_path = path or M.lua_springtime_path
    local with_path = checked_path .. file
    local f = io.open(with_path, "r")
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

function M.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.remove_trailing_comma(str)
    if string.sub(str, -1) == "," then
        str = string.sub(str, 1, -2)
    end
    return str
end

function M.check_plugin_dependencies()
    if vim.fn.executable("curl") == 0 then
        M.logger:error("curl is required. Install it to use this plugin.")
        return false
    end
    if vim.fn.executable("jq") == 0 then
        M.logger:error("jq is required. Install it to use this plugin.")
        return false
    end
    if vim.fn.executable("unzip") == 0 then
        M.logger:error("unzip is required. Install it to use this plugin.")
        return false
    end
    return true
end

return M
