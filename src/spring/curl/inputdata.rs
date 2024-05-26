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
    pub workspace: String,
    pub decompress: bool,
}

impl From<&SpringInputData> for String {
    fn from(value: &SpringInputData) -> Self {
        format!("type={}&language={}&packaging={}&bootVersion={}&javaVersion={}&groupId={}&artifactId={}&name={}&packageName={}&version={}&dependencies={}",
                value.project, value.language, value.packaging,
                value.spring_boot, value.java_version, value.project_group,
                value.project_artifact, value.project_name, value.project_package_name,
                value.project_version, value.dependencies.trim_end_matches(','))
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

#[cfg(test)]
mod inputdata_tests {
    use super::SpringInputData;

    #[test]
    fn test_inputdata() {
        let input_data = SpringInputData {
            project: "gradle-project".to_string(),
            language: "java".to_string(),
            packaging: "jar".to_string(),
            spring_boot: "3.2.5".to_string(),
            java_version: "21".to_string(),
            project_group: "com".to_string(),
            project_artifact: "demo".to_string(),
            project_name: "demo".to_string(),
            project_package_name: "com.example.demo".to_string(),
            project_version: "0.1.0".to_string(),
            dependencies: "data-jpa,".to_string(),
            workspace: "".to_string(),
            decompress: false,
        };
        let input_data = String::from(&input_data);
        assert_eq!(input_data.len(), 183);
    }
}
