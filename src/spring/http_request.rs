use std::{cell::RefCell, fs::File, io::Write};
use curl::easy::Easy;

const SPRING_URL: &str = "https://start.spring.io";

pub fn call_to_spring() -> Result<Vec<u8>, curl::Error> {
    let buffer = RefCell::new(Vec::new());
    let mut handle = Easy::new();
    handle.url(SPRING_URL).unwrap();
    handle.accept_encoding("application/json").unwrap();

    let mut transfer = handle.transfer();
    transfer
        .write_function(|data| {
            buffer.borrow_mut().extend_from_slice(data);
            Ok(data.len())
        })
        .unwrap();
    transfer.perform().unwrap();

    let buffer = buffer.borrow();
    Ok(buffer.to_vec())
}

pub fn create_project(project_name: &str, dependencies: &str) -> Result<(), String> {
    let mut easy = Easy::new();

    let mut path = SPRING_URL.to_string();
    path.push_str("/starter.zip?");
    path.push_str(dependencies);
    easy.url(&path)
        .map_err(|e| format!("Error calling spring: {e}"))?;
    easy.get(true).unwrap();

    let format = format!("Failed to create file {}", project_name);
    let mut file = File::create(project_name).expect(&format);

    easy.write_function(move |data| {
        file.write_all(data).unwrap();
        Ok(data.len())
    })
    .map_err(|e| format!("Error writing on disk {e}"))?;

    easy.perform().expect("Error performing easy curl");
    Ok(())
}
