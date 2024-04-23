use crate::spring::{
    constants::SPRING_URL,
    curl::inputdata::SpringInputData,
    errors::SpringtimeError,
    lua::{logger::Logger, utils::LogLevel, validator::Validator},
    zip::decompressor::decompress,
};

use curl::easy::Easy;
use std::{cell::RefCell, fs::File, io::Write, path::Path};

pub fn call_to_spring() -> Result<Vec<u8>, SpringtimeError> {
    let json = RefCell::new(Vec::new());
    let mut easy = Easy::new();
    easy.url(SPRING_URL).map_err(|e| {
        Logger::log(
            LogLevel::Error,
            &format!("Error calling Spring: {}", e.description()),
        );
        SpringtimeError::Curl(e)
    })?;

    easy.accept_encoding("application/json")
        .map_err(SpringtimeError::Curl)?;

    let mut transfer = easy.transfer();
    transfer
        .write_function(|data| {
            json.borrow_mut().extend_from_slice(data);
            Ok(data.len())
        })
        .map_err(SpringtimeError::Curl)?;
    transfer.perform().map_err(SpringtimeError::Curl)?;

    let json = json.borrow();
    Logger::log(LogLevel::Debug, "Call to Spring succeeded!");
    Ok(json.to_vec())
}

pub fn create_project(input_data: SpringInputData) -> Result<String, String> {
    Path::new(&input_data.path)
        .try_exists()
        .map_err(|e| format!("Path does not exists {}", e))?;

    if !input_data.dependencies.is_empty() {
        Validator::validate_libraries(&input_data.dependencies).map_err(|e| e.to_string())?;
    }

    Validator::validate_project_properties(&input_data).map_err(|e| e.to_string())?;

    let mut easy = Easy::new();
    let project_name = format!(
        "{}/{}{}",
        &input_data.path, &input_data.project_name, ".zip"
    );
    let string_data = String::from(&input_data);

    let path = format!("{}{}{}", SPRING_URL, "/starter.zip?", &string_data);
    easy.url(&path).map_err(|e| e.to_string())?;
    easy.get(true).map_err(|e| e.to_string())?;

    let mut file = File::create(&project_name).map_err(|e| e.to_string())?;

    easy.write_function(move |data| {
        file.write_all(data).unwrap();
        Ok(data.len())
    })
    .map_err(|e| e.to_string())?;

    easy.perform().map_err(|e| e.to_string())?;

    if input_data.decompress {
        let dest_directory = &format!("{}/{}/", &input_data.path, &input_data.project_name);
        decompress(&project_name, dest_directory).map_err(|e| e.to_string())?;
    }
    Ok(format!(
        "Project [{}] generated correctly in workspace [{}]",
        input_data.project_name, input_data.path
    ))
}
