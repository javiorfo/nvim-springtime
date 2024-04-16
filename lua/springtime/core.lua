local SETTINGS = require'springtime'.SETTINGS
local util = require'springtime.util'

local M = {}

--[[ local function create_dynamic_section(selected, values)
    local result = {}
    for i, v in pairs(values) do
        table.insert(result, { (selected == i and util.CHECKED_ICON or util.UNCHECKED_ICON) .. v })
    end
    return result
end ]]

local function create_dynamic_section(section)
    local config = SETTINGS.spring[section] or require('springtime.' ..section)
    local values = config.values or require('springtime.' ..section).values

    local result = {}
    for i, v in pairs(values) do
        table.insert(result, { (config.selected == i and util.CHECKED_ICON or util.UNCHECKED_ICON) .. v })
    end
    return result
end

local function select_or_unselect(lines, line_nr)
    for _, v in pairs(lines) do
        if v == line_nr then
            local selected = vim.fn.getline('.')
            local final = tostring(selected):gsub(util.UNCHECKED_ICON, util.CHECKED_ICON)
            vim.fn.setline(line_nr, final)
        else
            local unselected = vim.fn.getline(v)
            local final = tostring(unselected):gsub(util.CHECKED_ICON, util.UNCHECKED_ICON)
            vim.fn.setline(v, final)
        end
    end
end

function M.selection_key_event()
    vim.cmd[[setl ma]]
    local line_nr = vim.fn.line('.')

    if line_nr > 1 and line_nr < 5 then
       local lines = { 2, 3, 4 }
       select_or_unselect(lines, line_nr)
    end

    if line_nr > 6 and line_nr < 10 then
       local lines = { 7, 8, 9 }
       select_or_unselect(lines, line_nr)
    end

    if line_nr > 11 and line_nr < 14 then
       local lines = { 12, 13 }
       select_or_unselect(lines, line_nr)
    end

    if line_nr > 15 and line_nr < (M.java_version_section - 1) then
       local lines = {}
       for i = 15, M.java_version_section - 1 do table.insert(lines, i) end
       select_or_unselect(lines, line_nr)
    end

    if line_nr > M.java_version_section and line_nr < (M.project_metadata_section - 1) then
       local lines = {}
       for i = M.java_version_section, M.project_metadata_section - 1 do table.insert(lines, i) end
       select_or_unselect(lines, line_nr)
    end

    vim.cmd[[setl noma]]
end

function M.create_content()
    local content = {
        { "󰏖  Project", "Type" },
        { (SETTINGS.spring.project.selected == 1 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Gradle - Groovy" },
        { (SETTINGS.spring.project.selected == 2 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Gradle - Kotlin" },
        { (SETTINGS.spring.project.selected == 3 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Maven" },
        { "" },
        { "  Language", "Type" },
        { (SETTINGS.spring.language.selected == 1 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Java" },
        { (SETTINGS.spring.language.selected == 2 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Kotlin" },
        { (SETTINGS.spring.language.selected == 3 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Groovy" },
        { "" },
        { "  Packaging", "Type" },
        { (SETTINGS.spring.packaging.selected == 1 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "Jar" },
        { (SETTINGS.spring.packaging.selected == 2 and util.CHECKED_ICON or util.UNCHECKED_ICON) .. "War" },
        { "" },
        { "  Spring Boot", "Type" }
    }

    local spring_boot = create_dynamic_section("spring_boot")
--     local spring_boot = create_dynamic_section(SETTINGS.spring.spring_boot.selected, SETTINGS.spring.spring_boot.values)

    local java_version_label = {
        { "" },
        { " Java Version", "Type" }
    }

--     local java_version = create_dynamic_section(SETTINGS.spring.java_version.selected, SETTINGS.spring.java_version.values)
    local java_version = create_dynamic_section("java_version")
    M.java_version_section = #spring_boot + 17

    M.project_metadata_section = M.java_version_section + #java_version + 2

    local project_metadata = {
        { "" },
        { " Project Metadata", "Type" },
        { "Group        󰁕 " .. SETTINGS.spring.project_metadata.group },
        { "Artifact     󰁕 " .. SETTINGS.spring.project_metadata.artifact },
        { "Name         󰁕 " .. SETTINGS.spring.project_metadata.name },
        { "Package Name 󰁕 " .. SETTINGS.spring.project_metadata.package_name },
        { "" },
        { "  Dependencies", "Type" },
        { "" }
    }

    local function add_to_content(values)
        for _, v in pairs(values) do
            table.insert(content, v)
        end
    end

    add_to_content(spring_boot)
    add_to_content(java_version_label)
    add_to_content(java_version)
    add_to_content(project_metadata)

    return content
end

local function project_to_id(value)
    value = tostring(value)
    if value:find("Groovy") then
        return "gradle-project"
    elseif value:find("Kotlin") then
        return "gradle-project-kotlin"
    end
    return "maven-project"
end

function M.generate(values)
--     1) Project
--     2) Language
--     3) Packaging
--     4) Spring Boot
--     5) Java Version
--     6) Project Group
--     7) Project Artifact
--     8) Project Name
--     9) Project Package Name
--     10) Dependencies
    values[1] = project_to_id(values[1])
    values[2] = tostring(values[2]):lower()
    values[3] = tostring(values[3]):lower()
    print(vim.inspect(values))
end

return M
