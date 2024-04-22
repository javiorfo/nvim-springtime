use nvim_oxi::mlua::Table;

use crate::spring::errors::SpringtimeError;

use super::utils::{LuaUtils, Module, Variable};

pub struct LibraryValidator;

impl LibraryValidator {
    pub fn validate_libraries(libraries: &str) -> Result<(), SpringtimeError> {
        let values: Vec<&str> = libraries.split(',').filter(|&s| !s.is_empty()).collect();
        let lua_table = LuaUtils::get_lua_module::<Table>(
            Module("require'springtime.libraries'"),
            Variable("libraries"),
        )?;
        for v in values.iter() {
            Self::validate_one(v, &lua_table)?;
        }
        Ok(())
    }

    fn validate_one(library: &str, lua_table: &Table) -> Result<(), SpringtimeError> {
        let v = lua_table
            .clone()
            .pairs::<String, Table>()
            .map(|pair| (pair.unwrap().1).get::<&str, String>("insertText").unwrap())
            .any(|value| value == format!("{},", library));

        if v {
            Ok(())
        } else {
            Err(SpringtimeError::Generic(format!(
                "Library {} does not exist in libraries.lua",
                library
            )))
        }
    }
}
