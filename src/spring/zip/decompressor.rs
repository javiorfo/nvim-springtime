use std::fs::File;
use std::io::BufReader;
use std::path::Path;
use zip::read::ZipArchive;

use crate::spring::errors::SpringtimeError;

pub fn decompress(file_path: &str, dest_directory: &str) -> Result<(), SpringtimeError> {
    let file = File::open(file_path).map_err(SpringtimeError::Io)?;
    let mut archive = ZipArchive::new(BufReader::new(file)).map_err(SpringtimeError::ZipError)?;

    for i in 0..archive.len() {
        let mut file = archive.by_index(i).map_err(SpringtimeError::ZipError)?;
        let outpath = Path::new(dest_directory).join(file.name());

        if (file.name()).ends_with('/') {
            std::fs::create_dir_all(&outpath).map_err(SpringtimeError::Io)?;
        } else {
            if let Some(parent) = outpath.parent() {
                std::fs::create_dir_all(parent).map_err(SpringtimeError::Io)?;
            }
            let mut outfile = File::create(&outpath).map_err(SpringtimeError::Io)?;
            std::io::copy(&mut file, &mut outfile).map_err(SpringtimeError::Io)?;
        }
    }

    std::fs::remove_file(file_path).map_err(SpringtimeError::Io)?;
    Ok(())
}
