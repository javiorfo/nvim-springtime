use chrono::{Datelike, Local, Timelike};
use nvim_oxi::mlua::{lua, FromLua};

use crate::spring::errors::SpringtimeError;

pub struct LuaUtils;

pub struct Module<'a>(pub &'a str);
pub struct Variable<'a>(pub &'a str);

pub enum LogLevel {
    Error,
    Debug,
}

impl From<LogLevel> for &str {
    fn from(value: LogLevel) -> Self {
        match value {
            LogLevel::Error => "ERROR",
            LogLevel::Debug => "DEBUG",
        }
    }
}

// Check if log_debug is set to true
static mut IS_LOG_ENABLED: Option<bool> = None;
static mut LOG_FILE_PATH: Option<&'static str> = None;

impl LuaUtils {
    pub fn get_springtime_plugin_path() -> Result<String, SpringtimeError> {
        let lua_path = Self::get_lua_module(
            Module("require'springtime.util'.lua_springtime_path"),
            Variable("path"),
        )?;
        Ok(lua_path)
    }

    pub unsafe fn get_springtime_log_file() -> String {
        match LOG_FILE_PATH {
            Some(log_file_path) => log_file_path.to_string(),
            _ => Self::get_lua_module::<String>(
                    Module("require'springtime.util'.springtime_log_file"),
                    Variable("log_file"),
                ).unwrap_or("".to_string())
        }
    }

    pub fn get_lua_module<'lua, V: FromLua<'lua>>(
        module: Module,
        variable: Variable,
    ) -> Result<V, SpringtimeError> {
        let lua = lua();
        lua.load(format!("{} = {}", variable.0, module.0))
            .exec()
            .map_err(|_| SpringtimeError::Generic(format!("Lua {} does not exist", module.0)))?;

        let lua_module: V = lua.globals().get(variable.0).unwrap();
        Ok(lua_module)
    }

    pub unsafe fn is_log_enabled() -> bool {
        match IS_LOG_ENABLED {
            Some(value) => value,
            _ => Self::get_lua_module(
                Module("require'springtime'.SETTINGS.internal.log_debug"),
                Variable("log_debug"),
            )
            .unwrap_or(false),
        }
    }

    pub fn get_debug_header_log(log_level: LogLevel) -> String {
        let now = Local::now();
        let level: &str = log_level.into();
        format!(
            "[{}][{}/{}/{} {}:{}:{}]:",
            level,
            now.month(),
            now.day(),
            now.year(),
            now.hour(),
            now.minute(),
            now.second()
        )
    }
}
