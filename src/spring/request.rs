use super::{constants::SPRING_URL, errors::SpringtimeError, inputdata::SpringInputData};
use curl::easy::Easy;
use std::{cell::RefCell, fs::File, io::Write};

pub fn call_to_spring() -> Result<Vec<u8>, SpringtimeError> {
    let json = RefCell::new(Vec::new());
    let mut handle = Easy::new();
    handle.url(SPRING_URL).map_err(SpringtimeError::Curl)?;
    handle
        .accept_encoding("application/json")
        .map_err(SpringtimeError::Curl)?;

    let mut transfer = handle.transfer();
    transfer
        .write_function(|data| {
            json.borrow_mut().extend_from_slice(data);
            Ok(data.len())
        })
        .map_err(SpringtimeError::Curl)?;
    transfer.perform().map_err(SpringtimeError::Curl)?;

    let json = json.borrow();
    Ok(json.to_vec())
}

pub fn create_project(input_data: SpringInputData) -> Result<(), SpringtimeError> {
    let mut easy = Easy::new();
    let project_name = format!("{}/{}{}", &input_data.path, &input_data.project_name, ".zip");
    let string_data = String::from(&input_data);

    let path = format!("{}{}{}", SPRING_URL, "/starter.zip?", &string_data);
    println!("{}", path);
    easy.url(&path).map_err(SpringtimeError::Curl)?;
    easy.get(true).map_err(SpringtimeError::Curl)?;

    let mut file = File::create(project_name).map_err(SpringtimeError::Io)?;

    easy.write_function(move |data| {
        file.write_all(data).unwrap();
        Ok(data.len())
    })
    .map_err(SpringtimeError::Curl)?;

    easy.perform().map_err(SpringtimeError::Curl)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::spring::{request::create_project, inputdata::SpringInputData};

    #[test]
    fn test_create_project() {
        let input = SpringInputData {
            project: "gradle-project".to_string(),
            language: "java".to_string(),
            packaging: "jar".to_string(),
            spring_boot: "3.2.5".to_string(),
            java_version: "21".to_string(),
            project_group: "com.orfosys".to_string(),
            project_artifact: "orfosys".to_string(),
            project_name: "orfosys".to_string(),
            project_package_name: "com.orfosys.papa".to_string(),
            project_version: "0.1.0".to_string(),
            dependencies: "data-jpa,security".to_string(),
            path: "/home/javier/dir".to_string(),
            decompress: true,
        };
        println!("{}", String::from(&input));
        create_project(input).unwrap();
    }
}
