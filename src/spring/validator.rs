use nvim_oxi::mlua::{lua, Table};

use super::errors::SpringtimeError;

pub struct LibraryValidator;

impl LibraryValidator {
    pub fn validate_libraries(libraries: &str) -> Result<(), SpringtimeError> {
        let values: Vec<&str> = libraries.split(',').filter(|&s| !s.is_empty()).collect();
        for v in values.iter() {
            Self::validate_one(v)?;
        }
        Ok(())
    }

    fn validate_one(library: &str) -> Result<(), SpringtimeError> {
        let lua = lua();
        lua.load("libraries = require'springtime.libraries'")
            .exec()
            .map_err(|_| {
                SpringtimeError::Generic(String::from(
                    "Lua module springtime.libraries does not exist",
                ))
            })?;

        let lua_table: Table = lua.globals().get("libraries").unwrap();
        let v = lua_table
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
