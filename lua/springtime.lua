local M = {}

M.DEFAULT_OPTS = {
    project = {
        selected = 1
    },
    language = {
        selected = 1
    },
    spring_boot = {
        selected = 1,
        values = {
            "3.2.0 (SNAPSHOT)",
            "3.2.0 (M3)",
            "3.1.5 (SNAPSHOT)",
            "3.1.4",
            "3.0.12 (SNAPSHOT)",
            "3.0.11",
            "2.7.16",
        }
    },
    packaging = {
        selected = 1
    },
    java_version = {
        selected = 2,
        values = { 21, 17, 11, 8 }
    },
    project_metadata = {
        group = "com.example",
        artifact = "demo",
        name = "demo",
        description = "Description Project From Spring Boot",
        package_name = "com.example.demo"
    }
}

function M.setup(opts)
    -- TODO validate opts
end

return M
