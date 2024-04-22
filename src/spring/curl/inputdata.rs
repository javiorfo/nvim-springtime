use nvim_oxi::{
    conversion::FromObject,
    lua::{self, Poppable},
    Object,
};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct SpringInputData {
    pub project: String,
    pub language: String,
    pub packaging: String,
    pub spring_boot: String,
    pub java_version: String,
    pub project_group: String,
    pub project_artifact: String,
    pub project_name: String,
    pub project_package_name: String,
    pub project_version: String,
    pub dependencies: String,
    pub path: String,
    pub decompress: bool,
    pub log_debug: bool,
}

impl From<&SpringInputData> for String {
    fn from(value: &SpringInputData) -> Self {
        format!("type={}&language={}&packaging={}&bootVersion={}&javaVersion={}&groupId={}&artifactId={}&name={}&packageName={}&version={}&dependencies={}",
                value.project, value.language, value.packaging,
                value.spring_boot, value.java_version, value.project_group,
                value.project_artifact, value.project_name, value.project_package_name,
                value.project_version, value.dependencies)
    }
}

impl FromObject for SpringInputData {
    fn from_object(obj: Object) -> Result<Self, nvim_oxi::conversion::Error> {
        Self::deserialize(nvim_oxi::serde::Deserializer::new(obj)).map_err(Into::into)
    }
}

impl Poppable for SpringInputData {
    unsafe fn pop(lstate: *mut lua::ffi::lua_State) -> Result<Self, lua::Error> {
        let obj = Object::pop(lstate)?;
        Self::from_object(obj).map_err(lua::Error::pop_error_from_err::<Self, _>)
    }
}
