use nvim_oxi::mlua::Table;

use crate::spring::{constants::SpringtimeResult, curl::inputdata::SpringInputData, errors::SpringtimeError};

use super::{logger::Logger::*, utils::{LuaUtils, Module, Variable}};

pub struct Validator;

impl Validator {
    pub fn validate_libraries(libraries: &str) -> SpringtimeResult {
        let values: Vec<&str> = libraries.split(',').filter(|&s| !s.is_empty()).collect();
        Debug.log(&format!("Dependencies selected: {:?}", values));

        let lua_table = LuaUtils::get_lua_module::<Table>(
            Module("require'springtime.libraries'"),
            Variable("libraries"),
        )?;

        for v in values.iter() {
            Self::validate_one_library(v, &lua_table)?;
        }
        Ok(())
    }

    fn validate_one_library(library: &str, lua_table: &Table) -> SpringtimeResult {
        let v = lua_table
            .clone()
            .pairs::<String, Table>()
            .map(|pair| (pair.unwrap().1).get::<&str, String>("insertText").unwrap())
            .any(|value| value == format!("{},", library));

        if v {
            Debug.log(&format!("Library {} exists.", library));
            Ok(())
        } else {
            let message = format!("Library {} does not exist in Spring Boot official libraries.", library);
            Error.log(&message);
            Err(SpringtimeError::Generic(message))
        }
    }

    pub fn validate_project_properties(
        input_data: &SpringInputData,
    ) -> SpringtimeResult {
        let message = |section: &str| format!("Project Metadata {} must not be empty", section);

        if input_data.project_group.is_empty() {
            Err(SpringtimeError::Generic(message("Group")))
        } else if input_data.project_name.is_empty() {
            Err(SpringtimeError::Generic(message("Name")))
        } else if input_data.project_package_name.is_empty() {
            Err(SpringtimeError::Generic(message("Package Name")))
        } else if input_data.project_artifact.is_empty() {
            Err(SpringtimeError::Generic(message("Artifact")))
        } else {
            Ok(())
        }
    }
}

#[cfg(test)]
mod validator_tests {
    use crate::spring::curl::inputdata::SpringInputData;

    use super::Validator;

    #[test]
    fn test_project_properties() {
        let input_data = SpringInputData {
            project: "gradle-project".to_string(),
            language: "java".to_string(),
            packaging: "jar".to_string(),
            spring_boot: "3.2.5".to_string(),
            java_version: "21".to_string(),
            project_group: "com".to_string(),
            project_artifact: "demo".to_string(),
            project_name: "".to_string(),
            project_package_name: "com.example.demo".to_string(),
            project_version: "0.1.0".to_string(),
            dependencies: "data-jpa,".to_string(),
            workspace: "".to_string(),
            decompress: false,
        };
        let result = Validator::validate_project_properties(&input_data);
        assert!(result.is_err());

        let input_data = SpringInputData {
            project: "gradle-project".to_string(),
            language: "java".to_string(),
            packaging: "jar".to_string(),
            spring_boot: "3.2.5".to_string(),
            java_version: "21".to_string(),
            project_group: "com".to_string(),
            project_artifact: "demo".to_string(),
            project_name: "demo".to_string(),
            ..input_data
        };
        let result = Validator::validate_project_properties(&input_data);
        assert!(result.is_ok());
    }
}
