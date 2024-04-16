use nvim_oxi::{Dictionary, Function};
mod spring;
use spring::luafile::create_spring_libraries;

#[nvim_oxi::module]
fn springtime_rs() -> nvim_oxi::Result<Dictionary> {
    Ok(Dictionary::from_iter([(
        "download_libraries",
        Function::from_fn(download_libraries),
    )]))
}

fn download_libraries(_: ()) -> nvim_oxi::Result<()> {
    // TODO manage this error to log
    create_spring_libraries().expect("Could not download libraries!");
    Ok(())
}

#[cfg(test)]
mod tests {
    use std::env;

    use crate::spring::{http_request::create_project, luafile::{create_java_version_file, create_spring_boot_file}};
    use super::create_spring_libraries;

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
    fn test_create_java_version_file() {
        let _ = create_java_version_file();
    }

    #[test]
    fn test_create_spring_boot_file() {
        let _ = create_spring_boot_file();
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
