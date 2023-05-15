local M = {}
local popcorn = require'popcorn'

function M.open()
    local opts = {
        width = 50,
        height = 40,
        title = { "Springtime", "Boolean" },
        content = {
            { "󰏖  Project", "Type" },
            { "  Gradle (Groovy)" },
            { "󰄱  Gradle (Kotlin)" },
            { "󰄱  Maven" },
            { "" },
            { "  Language", "Type" },
            { "  Java" },
            { "󰄱  Kotlin" },
            { "󰄱  Groovy" },
            { "" },
            { "  Spring Boot", "Type" },
            { "󰄱  3.1.0 (SNAPSHOT)" },
            { "󰄱  3.1.0 (RC2)" },
            { "󰄱  3.1.0 (M2)" },
            { "󰄱  3.0.7 (SNAPSHOT)" },
            { "  3.0.6" },
            { "󰄱  2.7.12 (SNAPSHOT)" },
            { "󰄱  2.7.11" },
            { "" },
            { "  Packaging", "Type" },
            { "  Jar" },
            { "󰄱  War" },
            { "" },
            { " Java Version", "Type" },
            { "󰄱  20" },
            { "  17" },
            { "󰄱  11" },
            { "󰄱  8" },
            { "" },
            { " Project Metadata", "Type" },
            { "Group        󰁕 ", "Boolean" },
            { "Artifact     󰁕 ", "Boolean" },
            { "Name         󰁕 ", "Boolean" },
            { "Package Name 󰁕 ", "Boolean" },
            { "" },
            { "  Dependencies", "Type" },
        }
    }
    popcorn:new(opts):pop()
end

return M
