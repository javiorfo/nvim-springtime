use std::convert::Infallible;

use nvim_oxi::{Dictionary, Function, Object};
mod spring;
use spring::{
    curl::{inputdata::SpringInputData, request::create_project},
    lua::luafile::Luafile,
};

#[nvim_oxi::module]
fn springtime_rs() -> nvim_oxi::Result<Dictionary> {
    let create_project = Function::from_fn(|input_data: SpringInputData| {
        let result = create_project(input_data).unwrap_or(1);
        Ok::<u8, Infallible>(result)
    });

    let update_luafiles = Function::from_fn(|_: ()| {
        // TODO manage this error to log
        let result = Luafile::new().create_luafiles().unwrap_or(1);
        Ok::<u8, Infallible>(result)
    });

    let dictionary = Dictionary::from_iter([
        ("update", Object::from(update_luafiles)),
        ("create_project", Object::from(create_project)),
    ]);

    Ok(dictionary)
}
