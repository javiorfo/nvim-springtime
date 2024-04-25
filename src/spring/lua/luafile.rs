use crate::spring::{constants::*, curl::request::call_to_spring, errors::SpringtimeError};
use serde_json::Value;
use std::{fs::File, io::Write};

use super::{logger::Logger::*, utils::LuaUtils};

#[derive(Debug)]
pub struct Luafile {
    values: Option<Vec<u8>>,
    path: Option<String>,
}

impl Luafile {
    pub fn new() -> Self {
        Self {
            values: call_to_spring().ok(),
            path: LuaUtils::get_springtime_plugin_path().ok(),
        }
    }

    pub fn create_luafiles(&self) -> Result<u8, SpringtimeError> {
        self.create_libraries_luafile()?;
        self.create_java_version_luafile()?;
        self.create_spring_boot_luafile()?;
        Debug.log("Lua files created without errors.");
        Ok(0)
    }

    fn create_libraries_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.values {
            Some(json) => {
                let value: Value =
                    serde_json::from_slice(json.as_slice()).map_err(SpringtimeError::SerdeJson)?;
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

                let mut file = self.create_luafile(LIBRARIES_LUAFILE)?;

                writeln!(file, "return {{").map_err(|e| {
                    Error.log(&format!("Error writing file {:?}: {}", file, e));
                    SpringtimeError::Io(e)
                })?;

                for line in lua_list {
                    writeln!(file, "{}", line).map_err(|e| {
                        Error.log(&format!("Error writing file {:?}: {}", file, e));
                        SpringtimeError::Io(e)
                    })?;
                }

                writeln!(file, "}}").map_err(|e| {
                    Error.log(&format!("Error writing file {:?}: {}", file, e));
                    SpringtimeError::Io(e)
                })?;

                Ok(())
            }
            _ => {
                let message = format!("JSON is empty. Error calling {}", SPRING_URL);
                Error.log(&message);
                Err(SpringtimeError::Generic(message))
            }
        }
    }

    fn create_java_version_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.values {
            Some(json) => {
                let value: Value = serde_json::from_slice(json.as_slice()).unwrap();
                let default = value
                    .get(JAVA_VERSION)
                    .map(|v| v["default"].as_str().unwrap().parse::<u64>().unwrap())
                    .unwrap();

                let value = value.get(JAVA_VERSION).map(|v| v.get("values")).unwrap();
                let values = value.unwrap().as_array().unwrap();

                let versions = values
                    .iter()
                    .map(|v| v["id"].as_str().unwrap().parse::<u64>().unwrap())
                    .collect::<Vec<u64>>();

                let mut file = self.create_luafile(JAVA_VERSION_LUAFILE)?;

                let luafile = format!(
                    r#"return {{ selected = {}, values = {{ {} }} }}"#,
                    (versions.iter().position(|&s| s == default).unwrap_or(0) + 1),
                    versions
                        .iter()
                        .map(|v| v.to_string())
                        .collect::<Vec<String>>()
                        .join(", ")
                );

                file.write_all(luafile.as_bytes()).map_err(|e| {
                    Error.log(&format!("Error writing file {:?}: {}", file, e));
                    SpringtimeError::Io(e)
                })?;

                Ok(())
            }
            _ => {
                let message = format!("JSON is empty. Error calling {}", SPRING_URL);
                Error.log(&message);
                Err(SpringtimeError::Generic(message))
            }
        }
    }

    fn create_spring_boot_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.values {
            Some(json) => {
                let value: Value = serde_json::from_slice(json.as_slice()).unwrap();
                let default = value
                    .get(SPRING_BOOT_VERSION)
                    .map(|v| v["default"].as_str().unwrap())
                    .unwrap();

                let value = value
                    .get(SPRING_BOOT_VERSION)
                    .map(|v| v.get("values"))
                    .unwrap();
                let values = value.unwrap().as_array().unwrap();

                let versions = values
                    .iter()
                    .map(|v| v["name"].as_str().unwrap().to_string())
                    .collect::<Vec<String>>();

                let mut file = self.create_luafile(SPRING_BOOT_VERSION_LUAFILE)?;

                let luafile = format!(
                    r#"return {{ selected = {}, values = {{ {} }} }}"#,
                    (versions
                        .iter()
                        .position(|s| *s == default.replace(".RELEASE", ""))
                        .unwrap_or(0)
                        + 1),
                    versions
                        .iter()
                        .map(|v| format!(r#""{}""#, v.replace(" (", "-").replace(')', "")))
                        .collect::<Vec<String>>()
                        .join(", ")
                );

                file.write_all(luafile.as_bytes()).map_err(|e| {
                    Error.log(&format!("Error writing file {:?}: {}", file, e));
                    SpringtimeError::Io(e)
                })?;

                Ok(())
            }
            _ => {
                let message = format!("JSON is empty. Error calling {}", SPRING_URL);
                Error.log(&message);
                Err(SpringtimeError::Generic(message))
            }
        }
    }

    fn create_luafile(&self, luafile: &str) -> Result<File, SpringtimeError> {
        let path = self.path.as_ref().ok_or(SpringtimeError::Generic(
            "Springtime path is empty!".to_string(),
        ))?;

        let file = File::create(format!("{}{}", path, luafile)).map_err(|e| {
            Error.log(&format!("Error writing file {}/{}: {}", path, luafile, e));
            SpringtimeError::Io(e)
        })?;

        Debug.log(&format!("File {}/{} created correctly.", path, luafile));
        Ok(file)
    }
}
