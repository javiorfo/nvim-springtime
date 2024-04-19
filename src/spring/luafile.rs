use super::{constants::*, errors::SpringtimeError, request::call_to_spring};
use serde_json::Value;
use std::{env, fs::File, io::Write};

pub struct Luafile(Option<Vec<u8>>);

impl Luafile {
    pub fn new() -> Self {
        Self(call_to_spring().ok())
    }

    pub fn create_luafiles(&self) -> Result<(), SpringtimeError> {
       self.create_libraries_luafile()?; 
       self.create_java_version_luafile()?;
       self.create_spring_boot_luafile()?;
       Ok(())
    }

    fn create_libraries_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.0 {
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

                let mut file = self.create_luafile(LIBRARIES_LUAFILE).map_err(SpringtimeError::Io)?;
                writeln!(file, "return {{").map_err(SpringtimeError::Io)?;

                for line in lua_list {
                    writeln!(file, "{}", line).map_err(SpringtimeError::Io)?;
                }

                writeln!(file, "}}").map_err(SpringtimeError::Io)?;

                Ok(())
            },
            _ => Err(SpringtimeError::Generic(format!(
                "JSON is empty. Error calling {}",
                SPRING_URL
            )))
        }
    }

    fn create_java_version_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.0 {
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

                let mut file = self.create_luafile(JAVA_VERSION_LUAFILE).map_err(SpringtimeError::Io)?;

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
                    .map_err(SpringtimeError::Io)?;

                Ok(())
            },
            _ => Err(SpringtimeError::Generic(format!(
                "JSON is empty. Error calling {}",
                SPRING_URL
            )))
        }
    }

    fn create_spring_boot_luafile(&self) -> Result<(), SpringtimeError> {
        match &self.0 {
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
                    .map(|v| v["id"].as_str().unwrap().to_string())
                    .collect::<Vec<String>>();

                let mut file =
                    self.create_luafile(SPRING_BOOT_VERSION_LUAFILE).map_err(SpringtimeError::Io)?;

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
                    .map_err(SpringtimeError::Io)?;

                Ok(())
            },
            _ => Err(SpringtimeError::Generic(format!(
                "JSON is empty. Error calling {}",
                SPRING_URL
            )))
        }
    }

    fn create_luafile(&self, luafile: &str) -> Result<File, std::io::Error> {
        let file = File::create(format!(
            "{}{}",
            env::current_dir().unwrap().display(),
            luafile
        ))?;
        Ok(file)
    }
}





