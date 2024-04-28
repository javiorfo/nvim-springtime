use curl::Error as CurlError;
use serde_json::Error as SerdeJsonError;
use std::error::Error;
use std::io::Error as IOError;
use zip::result::ZipError;

#[derive(Debug)]
pub enum SpringtimeError {
    Io(IOError),
    ZipError(ZipError),
    Curl(CurlError),
    SerdeJson(SerdeJsonError),
    Generic(String),
}

// Error wrapper
pub type SpringtimeResult<T=()> = Result<T, SpringtimeError>;

impl std::fmt::Display for SpringtimeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SpringtimeError::Io(e) => write!(f, "IO internal error: {}", e),
            SpringtimeError::Curl(e) => write!(f, "Curl internal error: {}", e),
            SpringtimeError::SerdeJson(e) => write!(f, "SerdeJson internal error: {}", e),
            SpringtimeError::ZipError(e) => write!(f, "ZipError internal error: {}", e),
            SpringtimeError::Generic(e) => write!(f, "{}", e),
        }
    }
}

impl Error for SpringtimeError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            SpringtimeError::Io(e) => Some(e),
            SpringtimeError::Curl(e) => Some(e),
            SpringtimeError::SerdeJson(e) => Some(e),
            SpringtimeError::ZipError(e) => Some(e),
            SpringtimeError::Generic(_) => None,
        }
    }
}
