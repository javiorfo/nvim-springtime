use std::{fs::OpenOptions, io::Write};

use super::utils::{LogLevel, LuaUtils};

pub struct Logger;

impl Logger {
    pub fn log(log_level: LogLevel, message: &str) {
        unsafe {
            let is_log_enabled = LuaUtils::is_log_enabled();
            if is_log_enabled {
                let file_path = LuaUtils::get_springtime_log_file();
                let log_header = LuaUtils::get_debug_header_log(log_level);
                let data_to_append = format!("{} {}", log_header, message);

                let mut file = OpenOptions::new()
                    .create(true)
                    .append(true)
                    .open(file_path)
                    .unwrap();

                file.write_all(data_to_append.as_bytes()).unwrap();
            }
        }
    }
}
