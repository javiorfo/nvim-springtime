use std::fs::File;
use std::io::BufReader;
use std::path::Path;
use zip::read::ZipArchive;

use crate::spring::{errors::SpringtimeResult, errors::SpringtimeError, lua::logger::Logger::*};

pub fn decompress(file_path: &str, dest_directory: &str) -> SpringtimeResult {
    Debug.log(&format!(
        "File Path: {}, Dest Directory: {}",
        file_path, dest_directory
    ));
    let file = File::open(file_path).map_err(|e| {
        Error.log(&format!("Error opening file: {}", e));
        SpringtimeError::Io(e)
    })?;
    let mut archive = ZipArchive::new(BufReader::new(file)).map_err(|e| {
        Error.log(&format!("Error reading buffer zip archive: {}", e));
        SpringtimeError::ZipError(e)
    })?;

    for i in 0..archive.len() {
        let mut file = archive.by_index(i).map_err(|e| {
            Error.log(&format!("Error getting file by index: {}", e));
            SpringtimeError::ZipError(e)
        })?;
        let outpath = Path::new(dest_directory).join(file.name());

        if (file.name()).ends_with('/') {
            std::fs::create_dir_all(&outpath).map_err(|e| {
                Error.log(&format!("Error creating dir: {}", e));
                SpringtimeError::Io(e)
            })?;
        } else {
            if let Some(parent) = outpath.parent() {
                std::fs::create_dir_all(parent).map_err(|e| {
                    Error.log(&format!("Error creating dir: {}", e));
                    SpringtimeError::Io(e)
                })?;
            }
            let mut outfile = File::create(&outpath).map_err(|e| {
                Error.log(&format!("Error creating dest file: {}", e));
                SpringtimeError::Io(e)
            })?;
            std::io::copy(&mut file, &mut outfile).map_err(|e| {
                Error.log(&format!("Error copying file: {}", e));
                SpringtimeError::Io(e)
            })?;
        }
    }

    std::fs::remove_file(file_path).map_err(|e| {
        Error.log(&format!("Error deleting zip file: {}", e));
        SpringtimeError::Io(e)
    })?;
    Ok(())
}
