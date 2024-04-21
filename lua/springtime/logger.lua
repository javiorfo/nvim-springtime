local M = {}

local function logger(msg)
    return function(level)
        msg = string.format("  Springtime   %s", msg)
        vim.notify(msg, level)
    end
end

function M:new()
    local table = {}
    self.__index = self
    setmetatable(table, self)
    return table
end

function M:warn(msg)
    logger(msg)(vim.log.levels.WARN)
end

function M:error(msg)
    logger(msg)(vim.log.levels.ERROR)
end

function M:info(msg)
    logger(msg)(vim.log.levels.INFO)
end

return M
