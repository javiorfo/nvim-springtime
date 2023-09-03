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
            "3.2.0 (M2)",
            "3.1.4 (SNAPSHOT)",
            "3.1.3",
            "3.0.11 (SNAPSHOT)",
            "3.0.10",
            "2.7.15",
        }
    },
    packaging = {
        selected = 1
    },
    java_version = {
        selected = 2,
        values = { 20, 17, 11, 8 }
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
