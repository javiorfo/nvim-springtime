use curl::Error as CurlError;
use serde_json::Error as SerdeJsonError;
use std::error::Error;
use std::io::Error as IOError;

#[derive(Debug)]
pub enum SpringtimeError {
    Io(IOError),
    Curl(CurlError),
    SerdeJson(SerdeJsonError),
    Generic(String),
}

impl std::fmt::Display for SpringtimeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SpringtimeError::Io(e) => write!(f, "IO error: {}", e),
            SpringtimeError::Curl(e) => write!(f, "Curl error: {}", e),
            SpringtimeError::SerdeJson(e) => write!(f, "SerdeJson error: {}", e),
            SpringtimeError::Generic(e) => write!(f, "Generic error: {}", e),
        }
    }
}

impl Error for SpringtimeError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            SpringtimeError::Io(e) => Some(e),
            SpringtimeError::Curl(e) => Some(e),
            SpringtimeError::SerdeJson(e) => Some(e),
            SpringtimeError::Generic(_) => None,
        }
    }
}
