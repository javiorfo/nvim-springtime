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
