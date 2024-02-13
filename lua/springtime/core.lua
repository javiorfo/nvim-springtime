local DEFAULT_OPTS = require'springtime'.DEFAULT_OPTS
local util = require'springtime.util'

local M = {}

local function create_dynamic_section(selected, values)
    local result = {}
    for i, v in pairs(values) do
        table.insert(result, { (selected == i and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. v })
    end
    return result
end

-- TODO devolver content y los index de cada seccion
function M.create_content()
    local content = {
        { "󰏖  Project", "Type" },
        { (DEFAULT_OPTS.project.selected == 1 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Gradle (Groovy)" },
        { (DEFAULT_OPTS.project.selected == 2 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Gradle (Kotlin)" },
        { (DEFAULT_OPTS.project.selected == 3 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Maven" },
        { "" },
        { "  Language", "Type" },
        { (DEFAULT_OPTS.language.selected == 1 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Java" },
        { (DEFAULT_OPTS.language.selected == 2 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Kotlin" },
        { (DEFAULT_OPTS.language.selected == 3 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Groovy" },
        { "" },
        { "  Spring Boot", "Type" }
    }

    local spring_boot = create_dynamic_section(DEFAULT_OPTS.spring_boot.selected, DEFAULT_OPTS.spring_boot.values)

    local packaging = {
        { "" },
        { "  Packaging", "Type" },
        { (DEFAULT_OPTS.packaging.selected == 1 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "Jar" },
        { (DEFAULT_OPTS.packaging.selected == 2 and util.CHECKED_SELECTED_ICON or util.UNCHECKED_UNSELECTED_ICON) .. "War" },
        { "" },
        { " Java Version", "Type" }
    }

    local java_version = create_dynamic_section(DEFAULT_OPTS.java_version.selected, DEFAULT_OPTS.java_version.values)

    local project_metadata = {
        { "" },
        { " Project Metadata", "Type" },
        { "Group        󰁕 " .. DEFAULT_OPTS.project_metadata.group },
        { "Artifact     󰁕 " .. DEFAULT_OPTS.project_metadata.artifact },
        { "Name         󰁕 " .. DEFAULT_OPTS.project_metadata.name },
        { "Package Name 󰁕 " .. DEFAULT_OPTS.project_metadata.package_name },
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
    add_to_content(packaging)
    add_to_content(java_version)
    add_to_content(project_metadata)

    return content
end
return M
