use nvim_oxi::mlua::{lua, FromLua};

use crate::spring::{errors::SpringtimeError, lua::logger::Logger::*};

pub struct LuaUtils;

pub struct Module<'a>(pub &'a str);
pub struct Variable<'a>(pub &'a str);

impl LuaUtils {
    pub fn get_springtime_plugin_path() -> Result<String, SpringtimeError> {
        let lua_path = Self::get_lua_module(
            Module("require'springtime.util'.lua_springtime_path"),
            Variable("path"),
        )?;
        Debug.log(&format!("Lua Springtime path: {}", lua_path));
        Ok(lua_path)
    }

    pub fn get_lua_module<'lua, V: FromLua<'lua>>(
        module: Module,
        variable: Variable,
    ) -> Result<V, SpringtimeError> {
        let lua = lua();
        lua.load(format!("{} = {}", variable.0, module.0))
            .exec()
            .map_err(|e| {
                Error.log(&format!("Lua {} does not exist: {}", module.0, e));
                SpringtimeError::Generic(format!("Lua {} does not exist", module.0))
            })?;

        let lua_module: V = lua.globals().get(variable.0).unwrap();
        Debug.log(&format!("Lua module {} loaded", module.0));
        Ok(lua_module)
    }

    
}
