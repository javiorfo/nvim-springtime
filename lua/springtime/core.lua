local SETTINGS = require 'springtime'.SETTINGS
local constants = require 'springtime.constants'
local generator = require 'springtime.generator'
local spinetta = require 'spinetta'
local util = require 'springtime.util'

local M = {}

local function create_dynamic_section(section)
    local config = SETTINGS.spring[section] or dofile(util.lua_springtime_path .. section .. '.lua')
    local values = config.values or dofile(util.lua_springtime_path .. section .. '.lua').values
    local selected = config.selected or dofile(util.lua_springtime_path .. section .. '.lua').selected

    local result = {}
    for i, v in pairs(values) do
        table.insert(result, { (selected == i and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. v })
    end
    return result
end

local function select_or_unselect(lines, line_nr)
    for _, v in pairs(lines) do
        if v == line_nr then
            local selected = vim.fn.getline('.')
            local final = tostring(selected):gsub(constants.UNCHECKED_ICON, constants.CHECKED_ICON)
            vim.fn.setline(line_nr, final)
        else
            local unselected = vim.fn.getline(v)
            local final = tostring(unselected):gsub(constants.CHECKED_ICON, constants.UNCHECKED_ICON)
            vim.fn.setline(v, final)
        end
    end
end

function M.selection_key_event()
    vim.cmd [[setl ma]]
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

    vim.cmd [[setl noma]]
end

function M.create_content()
    local style = SETTINGS.dialog.style.section_link
    local content = {
        { constants.PROJECT_SECTION, style },
        { (SETTINGS.spring.project.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GRADLE_GROOVY },
        { (SETTINGS.spring.project.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GRADLE_KOTLIN },
        { (SETTINGS.spring.project.selected == 3 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.MAVEN },
        { "" },
        { constants.LANGUAGE_SECTION, style },
        { (SETTINGS.spring.language.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.JAVA },
        { (SETTINGS.spring.language.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.KOTLIN },
        { (SETTINGS.spring.language.selected == 3 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GROOVY },
        { "" },
        { constants.PACKAGING_SECTION, style },
        { (SETTINGS.spring.packaging.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.JAR },
        { (SETTINGS.spring.packaging.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.WAR },
        { "" },
        { constants.SPRING_BOOT_SECTION, style }
    }

    local spring_boot = create_dynamic_section("spring_boot")

    local java_version_label = {
        { "" },
        { constants.JAVA_VERSION_SECTION, style }
    }

    local java_version = create_dynamic_section("java_version")
    M.java_version_section = #spring_boot + 17

    M.project_metadata_section = M.java_version_section + #java_version + 2

    local project_metadata = {
        { "" },
        { constants.PROJECT_METADATA_SECTION, style },
        { "Group        󰁕 " .. SETTINGS.spring.project_metadata.group },
        { "Artifact     󰁕 " .. SETTINGS.spring.project_metadata.artifact },
        { "Name         󰁕 " .. SETTINGS.spring.project_metadata.name },
        { "Package Name 󰁕 " .. SETTINGS.spring.project_metadata.package_name },
        { "" },
        { constants.DEPENDENCIES_SECTION, style },
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

function M.generate(values)
    local user_input = "y"
    if SETTINGS.dialog.confirmation then
        user_input = vim.fn.input(string.format("Do you want to generate project [%s]? y/n: ", values[8]))
    end

    if tostring(user_input):lower() == "y" then
        vim.cmd [[redraw]]
        util.logger:debug("Values to generate project: " .. vim.inspect(values))

        local ok = generator.create_project(values)
        if ok then
            util.logger:info(string.format("  [%s] generated correctly in workspace [%s]", util.trim(values[8]), SETTINGS.workspace.path))
            if SETTINGS.workspace.open_auto then
                vim.cmd(string.format("e %s/%s", SETTINGS.workspace.path, util.trim(values[8])))
            end
        else
            util.logger:error("  Error generating project. Check the logs with :SpringtimeLogs command")
        end
    else
        vim.cmd [[redraw]]
    end
end

function M.update()
    if not util.check_plugin_dependencies() then
        return
    end

    local root_path = util.lua_springtime_path:gsub("/lua/springtime", "")
    local script = string.format(
    "%sscript/build.sh %s 2> >( while read line; do echo \"[ERROR][$(date '+%%m/%%d/%%Y %%T')]: ${line}\"; done >> %s)",
        root_path, util.lua_springtime_path, util.springtime_log_file)
    local spinner = spinetta:new {
        main_msg = "  Springtime   Updating plugin... ",
        speed_ms = 100,
        on_success = function()
            util.logger:info("  Springtime is ready to be used!")
        end,
        on_interrupted = function()
            vim.cmd("redraw")
            local msg = "Process interrupted!"
            util.logger:info(msg)
        end
    }

    spinner:start(spinetta.job_to_run(script))
end

function M.show_logs()
    vim.cmd(string.format("vsp %s | normal G", util.springtime_log_file))
end

function M.open()
    if not util.check_if_file_exists('java_version.lua') or not util.check_if_file_exists('spring_boot.lua') then
        util.logger:warn(":SpringtimeUpdate must be executed before using this plugin.")
        return
    end

    if not util.check_plugin_dependencies() then
        return
    end
    require'springtime.ui'.open()
end

return M
