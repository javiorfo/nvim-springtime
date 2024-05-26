use std::{fs::OpenOptions, io::Write};

use chrono::Local;

use super::utils::{LuaUtils, Module, Variable};

pub enum Logger {
    Error,
    Debug,
}

static mut IS_LOG_ENABLED: Option<bool> = None;
static mut LOG_FILE_PATH: Option<&'static str> = None;

impl Logger {
    pub fn log(&self, message: &str) {
        let log_level = match self {
            Self::Error => "ERROR",
            Self::Debug => "DEBUG",
        };
        unsafe {
            let is_log_enabled = Self::is_log_enabled();
            if is_log_enabled {
                let file_path = Self::get_springtime_log_file();
                let log_header = Self::get_header_log(log_level);
                let data_to_append = format!("{} {}\n", log_header, message);

                let mut file = OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(file_path)
                    .unwrap();

                file.write_all(data_to_append.as_bytes()).unwrap();
            }
        }
    }

    unsafe fn get_springtime_log_file() -> String {
        match LOG_FILE_PATH {
            Some(log_file_path) => log_file_path.to_string(),
            _ => LuaUtils::get_lua_module::<String>(
                    Module("require'springtime.util'.springtime_log_file"),
                    Variable("log_file"),
                ).unwrap_or("".to_string())
        }
    }
    
    unsafe fn is_log_enabled() -> bool {
        match IS_LOG_ENABLED {
            Some(value) => value,
            _ => LuaUtils::get_lua_module(
                Module("require'springtime'.SETTINGS.internal.log_debug"),
                Variable("log_debug"),
            )
            .unwrap_or(false),
        }
    }

    fn get_header_log(log_level: &str) -> String {
        let now = Local::now();
        let date = now.format("[%m/%d/%Y %H:%M:%S]").to_string();
        format!(
            "[{}]{}:",
            log_level,
            date 
        )
    }
}
