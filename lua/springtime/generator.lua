local util = require 'springtime.util'
local constants = require 'springtime.constants'
local SETTINGS = require 'springtime'.SETTINGS

local M = {}

local function project_to_id(value)
    if value == constants.GRADLE_GROOVY then
        return "gradle-project"
    end
    if value == constants.GRADLE_KOTLIN then
        return "gradle-project-kotlin"
    end
    return "maven-project"
end


local function split(str)
    local delimiter = ","
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        if match ~= "" then
            table.insert(result, match)
        end
    end

    local log = vim.inspect(result) or 'NONE'
    util.logger:debug('split dependencies: ' .. log)

    return result
end

local function validate_dependencies(dependencies)
    local _, libraries = pcall(dofile, util.lua_springtime_path .. 'libraries.lua')
    local dependencies_to_tbl = split(dependencies)

    for _, v in pairs(dependencies_to_tbl) do
        local is_valid = false
        for _, library in ipairs(libraries) do
            if library.insertText:sub(1, -2) == v then
                is_valid = true
                util.logger:debug("Library: " .. library.label .. " Version range: " .. library.versionRange)
                break
            end
        end
        if not is_valid then
            return false, v .. " is not a valid library"
        end
    end

    return true, nil
end

local function generate(input)
    local project_folder = string.format("%s/%s", input.workspace, input.project_name)
    local zip_file = string.format("%s.zip", project_folder)
    local command = string.format([[curl -G %s/starter.zip -d type=%s -d language=%s -d packaging=%s -d bootVersion=%s -d javaVersion=%s -d groupId=%s -d artifactId=%s -d name=%s -d packageName=%s -d version=%s %s -o %s 2> >( while read line; do echo \"[ERROR][$(date '+%%m/%%d/%%Y %%T')]: ${line}\"; done >> %s) %s; echo $?]],
        util.spring_url,
        input.project,
        input.language,
        input.packaging,
        input.spring_boot,
        input.java_version,
        input.project_group,
        input.project_artifact,
        input.project_name,
        input.project_package_name,
        input.project_version,
        input.dependencies ~= "" and "-d dependencies=" .. input.dependencies or "",
        zip_file,
        util.springtime_log_file,
        input.decompress and string.format("&& unzip -q %s -d %s && rm %s", zip_file, project_folder, zip_file) or ""
    )

    util.logger:debug("Curl generated: " .. command)

    local ok = vim.fn.system(command)

    return tonumber(ok) == 0
end

function M.create_project(values)
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
        workspace = SETTINGS.workspace.path,
        decompress = SETTINGS.workspace.decompress,
    }

    if input.project_group == "" then
        return false, "Project Metadata Group could not be empty"
    end
    if input.project_artifact == "" then
        return false, "Project Metadata Artifact could not be empty"
    end
    if input.project_name == "" then
        return false, "Project Metadata Name could not be empty"
    end
    if input.project_package_name == "" then
        return false, "Project Metadata Package Name could not be empty"
    end

    if input.dependencies ~= "" then
        input.dependencies, _ = string.gsub(input.dependencies, " ", "")
        local is_valid, msg = validate_dependencies(input.dependencies)
        if is_valid then
            input.dependencies = util.remove_trailing_comma(util.trim(input.dependencies))
        else
            return false, msg
        end
    end

    return generate(input)
end

return M
