use curl::easy::Easy;
use nvim_oxi::{Dictionary, Function};
use serde_json::Value;
use std::{cell::RefCell, env, error::Error, fs::File, io::Write};

const SPRING_URL: &str = "https://start.spring.io";

#[nvim_oxi::module]
fn springtime_rs() -> nvim_oxi::Result<Dictionary> {
    Ok(Dictionary::from_iter([
        ("generate_libraries", Function::from_fn(generate_libraries)),
    ]))
}

fn generate_libraries(_: ()) -> nvim_oxi::Result<()> {
    create_spring_libraries().unwrap();
    Ok(())
}

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

fn call_to_spring() -> Result<Vec<u8>, curl::Error> {
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
fn create_spring_libraries() -> Result<(), String> {
    match call_to_spring() {
        Ok(buffer) => {
            let value: Value = serde_json::from_slice(buffer.as_slice()).unwrap();
            let value = value.get("dependencies").map(|v| v.get("values")).unwrap();
            let values = value.unwrap().as_array().unwrap();
            let lua_list = values
                .iter()
                .flat_map(|v| {
                    v.get("values")
                        .unwrap()
                        .as_array()
                        .unwrap()
                        .iter()
                        .map(|v| {
                            format!(
                                r#"    {{ label = {}, insertText = {} }},"#,
                                v.get("name").unwrap(),
                                v.get("id").unwrap()
                            )
                        })
                })
                .collect::<Vec<String>>();

            let mut file = File::create(format!(
                "{}/lua/springtime/libraries.lua",
                env::current_dir().unwrap().display()
            ))
            .map_err(|err| format!("Error creating libraries.lua -> {}", err))?;

            writeln!(file, "return {{")
                .map_err(|err| format!("Error writing line in file libraries.lua -> {}", err))?;

            for line in lua_list {
                writeln!(file, "{}", line).map_err(|err| {
                    format!("Error writing line in file libraries.lua -> {}", err)
                })?;
            }

            writeln!(file, "}}")
                .map_err(|err| format!("Error writing line in file libraries.lua -> {}", err))?;

            Ok(())
        }
        Err(error) => Err(format!("Error calling spring initializr {}", error)),
    }
}

#[cfg(test)]
mod tests {
    use std::env;

    use super::{create_project, create_spring_libraries};

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
    fn test_create_spring_libraries() {
        let _ = create_spring_libraries();
    }

    #[test]
    fn files() {
        if let Ok(current_dir) = env::current_dir() {
            let parent_dir = current_dir;
            println!("Absolute path two folders up: {}", parent_dir.display());
        } else {
            eprintln!("Failed to get current directory");
        }
    }
}
