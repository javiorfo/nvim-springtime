local M = {}

M.DEFAULT_OPTS = {
    project = {
        selected = 1
    },
    language = {
        selected = 1
    },
    spring_boot = {
        selected = 4,
        values = {
            "3.3.0 (SNAPSHOT)",
            "3.3.0 (M1)",
            "3.2.3 (SNAPSHOT)",
            "3.2.2",
            "3.1.9 (SNAPSHOT)",
            "3.1.8",
            "2.7.16",
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
        description = "Description Project From Spring Boot",
        package_name = "com.example.demo"
    }
}

function M.setup(opts)
    -- TODO validate opts
end

return M
