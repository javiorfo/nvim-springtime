local SETTINGS = require 'springtime'.SETTINGS
local constants = require 'springtime.constants'
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
        { constants.PROJECT_SECTION,                                                                                                style },
        { (SETTINGS.spring.project.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GRADLE_GROOVY },
        { (SETTINGS.spring.project.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GRADLE_KOTLIN },
        { (SETTINGS.spring.project.selected == 3 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.MAVEN },
        { "" },
        { constants.LANGUAGE_SECTION,                                                                                               style },
        { (SETTINGS.spring.language.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.JAVA },
        { (SETTINGS.spring.language.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.KOTLIN },
        { (SETTINGS.spring.language.selected == 3 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.GROOVY },
        { "" },
        { constants.PACKAGING_SECTION,                                                                                              style },
        { (SETTINGS.spring.packaging.selected == 1 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.JAR },
        { (SETTINGS.spring.packaging.selected == 2 and constants.CHECKED_ICON or constants.UNCHECKED_ICON) .. constants.WAR },
        { "" },
        { constants.SPRING_BOOT_SECTION,                                                                                            style }
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

    util.logger:debug("Popcorn content: " .. vim.inspect(content))
    return content
end

local function project_to_id(value)
    if value == constants.GRADLE_GROOVY then
        return "gradle-project"
    end
    if value == constants.GRADLE_KOTLIN then
        return "gradle-project-kotlin"
    end
    return "maven-project"
end

function M.generate(values)
    local user_input = "y"
    if SETTINGS.dialog.confirmation then
        user_input = vim.fn.input(string.format("Do you want to generate project [%s]? y/n: ", values[8]))
    end

    if tostring(user_input):lower() == "y" then
        vim.cmd [[redraw]]
        util.logger:debug("Values to generate project: ", vim.inspect(values))

        local input = {
            project = project_to_id(values[1]),
            language = tostring(values[2]):lower(),
            packaging = tostring(values[3]):lower(),
            spring_boot = values[4],
            java_version = values[5],
            project_group = util.trim(values[6]),
            project_artifact = util.trim(values[7]),
            project_name = util.trim(values[8]),
            project_package_name = util.trim(values[9]),
            project_version = SETTINGS.spring.project_metadata.version,
            dependencies = values[10],
            path = SETTINGS.directory.path,
            decompress = SETTINGS.directory.decompress,
        }

        local ok, message = require 'springtime_rs'.create_project(input)
        if ok then
            util.logger:info(message)
            if SETTINGS.directory.open_auto then
                vim.cmd(string.format("e %s/%s", SETTINGS.directory.path, input.project_name))
            end
        else
            util.logger:error(message)
        end
    else
        vim.cmd [[redraw]]
    end
end

function M.build()
    local root_path = util.lua_springtime_path:gsub("/lua/springtime", "")
    local script = string.format(
    "%sinstall.sh %s 2> >( while read line; do echo \"[ERROR][$(date '+%%m/%%d/%%Y %%T')]: ${line}\"; done >> %s)", root_path,
        root_path, util.springtime_log_file)
    local is_ok = false
    local spinner = spinetta:new {
        main_msg = "  Springtime   Building plugin. Please wait ",
        on_success = function()
            if is_ok then
                util.logger:info("Done! Springtime is ready to be used!")
--                 M.update()
            else
                util.logger:error("An error ocurred during building. Check the Logs for further information.")
            end
        end,
        on_interrupted = function()
            vim.cmd("redraw")
            local msg = "Call interrupted!"
            util.logger:info(msg)
        end
    }

    local function job_to_run(job_string)
        local pid = vim.fn.jobpid(vim.fn.jobstart(job_string, {
            on_exit = function(_, status)
                if status == 0 then
                    is_ok = true
                end
            end
        }))
        return spinetta.break_when_pid_is_complete(pid)
    end

    spinner:start(job_to_run(script))
end

function M.update()
    local spinner = spinetta:new {
        main_msg = "  Springtime   Updating from https://start.spring.io ",
        on_success = function()
            if require 'springtime_rs'.update() == 0 then
                util.logger:info("Done! Springtime is ready to be used!")
            else
                util.logger:error("An error ocurred during update. Check the Logs for further information.")
            end
        end,
        on_interrupted = function()
            vim.cmd("redraw")
            local msg = "Call interrupted!"
            util.logger:info(msg)
        end
    }

    spinner:start(spinetta.job_to_run("sleep 1"))
end

function M.show_logs()
    vim.cmd(string.format("vsp %s | normal G", util.springtime_log_file))
end

function M.open()
    if not util.check_if_file_exists('java_version.lua') or not util.check_if_file_exists('spring_boot.lua')
        or not util.check_if_file_exists('springtime_rs.so', util.lua_springtime_path:gsub("/springtime", "")) then
        util.logger:warn(":SpringtimeBuild must be executed to build this plugin before using it.")
        return
    else
        require'springtime.ui'.open()
    end
end

return M
