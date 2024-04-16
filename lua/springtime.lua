local M = {}

M.SETTINGS = {
    spring = {
        project = {
            selected = 1
        },
        language = {
            selected = 1
        },
        packaging = {
            selected = 1
        },
        spring_boot = {
            selected = 4,
        },
        java_version = {
            selected = 2,
        },
        project_metadata = {
            group = "com.example",
            artifact = "demo",
            name = "demo",
            package_name = "com.example.demo",
            description = "Project generated with nvim-springtime",
            version = "0.0.1-SNAPSHOT"
        }
    },
    actions = {
        selection_keymap = "<C-Space>",
        generate_keymap = "<C-CR>",
        directory = {
            path = ".",
            decompress = true,
            open_auto = true
        }
    }
}

function M.setup(opts)
    -- TODO validate opts
end

return M
