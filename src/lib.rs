use curl::easy::Easy;
use serde_json::Value;
use std::{cell::RefCell, collections::HashMap, fs::File, io::Write};

const SPRING_URL: &str = "https://start.spring.io";

fn create_project(project_name: &str, dependencies: &str) -> Result<(), String> {
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

fn call_spring() -> Result<Vec<u8>, curl::Error> {
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

// TODO validar librerias en el curl para armar el proyecto
fn get_spring_libraries() -> Result<HashMap<String, String>, String> {
    match call_spring() {
        Ok(buffer) => {
            let value: Value = serde_json::from_slice(buffer.as_slice()).unwrap();
            let value = value.get("dependencies").map(|v| v.get("values")).unwrap();
            let values = value.unwrap().as_array().unwrap();
            let result = values
                .iter()
                .flat_map(|v| {
                    v.get("values")
                        .unwrap()
                        .as_array()
                        .unwrap()
                        .iter()
                        .map(|v| {
                            (
                                v.get("id").unwrap().to_string(),
                                v.get("name").unwrap().to_string(),
                            )
                        })
                })
                .collect::<HashMap<String, String>>();
            Ok(result)
        }
        Err(_error) => Err("".to_string()),
    }
}

#[cfg(test)]
mod tests {
    use super::{create_project, get_spring_libraries};

    #[test]
    fn test_create_project() {
        let project_name = "demo.zip";
        let dependencies = "dependencies=web,security&javaVersion=21";
        if let Err(err) = create_project(project_name, dependencies) {
            eprintln!("Error {err}");
        } else {
            println!("Done!");
        }
    }

    #[test]
    fn test_get_spring_libraries() {
        let libraries = get_spring_libraries().unwrap();
        libraries.iter().for_each(|(k, v)| println!("{k} {v}"));
    }
}
