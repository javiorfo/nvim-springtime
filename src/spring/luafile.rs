use std::{env, fs::File, io::Write};
use serde_json::Value;
use super::http_request::call_to_spring;

// TODO validar librerias en el curl para armar el proyecto
pub fn create_spring_libraries() -> Result<(), String> {
    match call_to_spring() {
        Ok(buffer) => {
            let value: Value = serde_json::from_slice(buffer.as_slice()).unwrap();
            let value = value.get("dependencies").map(|v| v.get("values")).unwrap();
            let values = value.unwrap().as_array().unwrap();
            let lua_list = values
                .iter()
                .flat_map(|v| {
                    v.get("values")
                        .unwrap()
                        .as_array()
                        .unwrap()
                        .iter()
                        .map(|v| {
                            format!(
                                r#"    {{ label = "{}", insertText = "{}," }},"#,
                                v["name"].as_str().unwrap(),
                                v["id"].as_str().unwrap()
                            )
                        })
                })
                .collect::<Vec<String>>();

            let mut file = File::create(format!(
                "{}/lua/springtime/libraries.lua",
                env::current_dir().unwrap().display()
            ))
            .map_err(|err| format!("Error creating libraries.lua: {}", err))?;

            writeln!(file, "return {{")
                .map_err(|err| format!("Error writing line in file libraries.lua: {}", err))?;

            for line in lua_list {
                writeln!(file, "{}", line)
                    .map_err(|err| format!("Error writing line in file libraries.lua: {}", err))?;
            }

            writeln!(file, "}}")
                .map_err(|err| format!("Error writing line in file libraries.lua: {}", err))?;

            Ok(())
        }
        Err(error) => Err(format!("Error calling spring initializr: {}", error)),
    }
}

pub fn create_java_version_file() -> Result<(), String> {
    match call_to_spring() {
        Ok(buffer) => {
            let value: Value = serde_json::from_slice(buffer.as_slice()).unwrap();
            let default = value
                .get("javaVersion")
                .map(|v| v["default"].as_str().unwrap().parse::<u64>().unwrap())
                .unwrap();

            let value = value.get("javaVersion").map(|v| v.get("values")).unwrap();
            let values = value.unwrap().as_array().unwrap();

            let versions = values
                .iter()
                .map(|v| v["id"].as_str().unwrap().parse::<u64>().unwrap())
                .collect::<Vec<u64>>();

            let mut file = File::create(format!(
                "{}/lua/springtime/java_version.lua",
                env::current_dir().unwrap().display()
            ))
            .map_err(|err| format!("Error creating java_version.lua: {}", err))?;

            let luafile = format!(
                r#"return {{ selected = {}, values = {{ {} }} }}"#,
                (versions.iter().position(|&s| s == default).unwrap() + 1),
                versions
                    .iter()
                    .map(|v| v.to_string())
                    .collect::<Vec<String>>()
                    .join(", ")
            );

            file.write_all(luafile.as_bytes())
                .map_err(|err| format!("Error writing java_version.lua: {}", err))?;

            Ok(())
        }
        Err(error) => Err(format!("Error calling spring initializr: {}", error)),
    }
}

pub fn create_spring_boot_file() -> Result<(), String> {
    match call_to_spring() {
        Ok(buffer) => {
            let value: Value = serde_json::from_slice(buffer.as_slice()).unwrap();
            let default = value
                .get("bootVersion")
                .map(|v| v["default"].as_str().unwrap())
                .unwrap();

            let value = value.get("bootVersion").map(|v| v.get("values")).unwrap();
            let values = value.unwrap().as_array().unwrap();

            let versions = values
                .iter()
                .map(|v| v["id"].as_str().unwrap().to_string())
                .collect::<Vec<String>>();

            let mut file = File::create(format!(
                "{}/lua/springtime/spring_boot.lua",
                env::current_dir().unwrap().display()
            ))
            .map_err(|err| format!("Error creating spring_boot.lua: {}", err))?;

            let luafile = format!(
                r#"return {{ selected = {}, values = {{ {} }} }}"#,
                (versions.iter().position(|s| s == default).unwrap() + 1),
                versions
                    .iter()
                    .map(|v| format!(r#""{}""#, v.replace(".RELEASE", "")))
                    .collect::<Vec<String>>()
                    .join(", ")
            );

            file.write_all(luafile.as_bytes())
                .map_err(|err| format!("Error writing spring_boot.lua: {}", err))?;

            Ok(())
        }
        Err(error) => Err(format!("Error calling spring initializr: {}", error)),
    }
}

