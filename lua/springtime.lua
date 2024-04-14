local M = {}

M.SETTINGS = {
    spring = {
        project = {
            selected = 1
        },
        language = {
            selected = 1
        },
        spring_boot = {
            selected = 4,
            values = {
                "3.3.0.BUILD-SNAPSHOT",
                "3.3.0.M3",
                "3.2.5.BUILD-SNAPSHOT",
                "3.2.4",
                "3.1.11.BUILD-SNAPSHOT",
                "3.1.10",
                "2.7.18",
            }
        },
        packaging = {
            selected = 1
        },
        java_version = {
            selected = 2,
            values = { 21, 17, 11 }
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
