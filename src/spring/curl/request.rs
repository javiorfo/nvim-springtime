use crate::spring::{
    constants::{SpringtimeResult, SPRING_URL},
    curl::inputdata::SpringInputData,
    errors::SpringtimeError,
    lua::{logger::Logger::*, validator::Validator},
    zip::decompressor::decompress,
};

use curl::easy::Easy;
use std::{cell::RefCell, fs::File, io::Write, path::Path};

pub fn call_to_spring() -> SpringtimeResult<Vec<u8>> {
    let json = RefCell::new(Vec::new());
    let mut easy = Easy::new();
    easy.url(SPRING_URL).map_err(|e| {
        Error.log(&format!("Error Spring URL: {}", e.description()));
        SpringtimeError::Curl(e)
    })?;

    easy.accept_encoding("application/json")
        .map_err(SpringtimeError::Curl)?;
    {
        let mut transfer = easy.transfer();
        transfer
            .write_function(|data| {
                json.borrow_mut().extend_from_slice(data);
                Ok(data.len())
            })
            .map_err(|e| {
                Error.log(&format!(
                    "Error copying response to vector: {}",
                    e.description()
                ));
                SpringtimeError::Curl(e)
            })?;

        transfer.perform().map_err(|e| {
            Error.log(&format!("Error performing calling: {}", e.description()));
            SpringtimeError::Curl(e)
        })?;
    }
    let json = json.borrow();
    Debug.log(&format!(
        "Response Status: {}",
        easy.response_code().unwrap()
    ));
    Ok(json.to_vec())
}

pub fn create_project(input_data: SpringInputData) -> Result<String, String> {
    Debug.log(&format!("Input Data: {:?}", input_data));
    Path::new(&input_data.workspace)
        .try_exists()
        .map_err(|e| format!("  Workspace does not exists {}", e))?;

    if !input_data.dependencies.is_empty() {
        Validator::validate_libraries(&input_data.dependencies).map_err(|e| format!("  {}", e))?;
    }

    Validator::validate_project_properties(&input_data).map_err(|e| format!("  {}", e))?;

    let mut easy = Easy::new();
    let project_name = format!("{}/{}.zip", &input_data.workspace, &input_data.project_name);
    let string_data = String::from(&input_data);
    Debug.log(&format!("Query params: {}", string_data));

    let path = format!("{}/starter.zip?{}", SPRING_URL, &string_data);
    easy.url(&path).map_err(|e| format!("  {}", e))?;
    easy.get(true).map_err(|e| format!("  {}", e))?;

    let mut file = File::create(&project_name).map_err(|e| format!("  {}", e))?;

    easy.write_function(move |data| {
        file.write_all(data).unwrap();
        Ok(data.len())
    })
    .map_err(|e| format!("  {}", e))?;

    easy.perform().map_err(|e| format!("  {}", e))?;

    if input_data.decompress {
        let dest_directory = &format!("{}/{}/", &input_data.workspace, &input_data.project_name);
        decompress(&project_name, dest_directory).map_err(|e| format!("  {}", e))?;
    }
    Ok(format!(
        "  [{}] generated correctly in workspace [{}]",
        input_data.project_name, input_data.workspace
    ))
}

#[cfg(test)]
mod request_tests {
    use super::call_to_spring;

    #[test]
    fn test_call_to_spring() {
        let result = call_to_spring();
        assert!(result.is_ok());
    }
}
