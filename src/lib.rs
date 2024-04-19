use std::convert::Infallible;

use nvim_oxi::{
    Dictionary, Function, Object,
};
mod spring;
use spring::{inputdata::SpringInputData, luafile::Luafile};

use crate::spring::request::create_project;

#[nvim_oxi::module]
fn springtime_rs() -> nvim_oxi::Result<Dictionary> {
    let create_project = Function::from_fn(|input_data: SpringInputData| {
        println!("{:?}", input_data);
        let _ = create_project(input_data);
        Ok::<_, Infallible>(())
    });

    let update_luafiles = Function::from_fn(|_: ()| {
        // TODO manage this error to log
        let luafile = Luafile::new();
        let _ = luafile.create_luafiles();
        Ok::<_, Infallible>(())
    });

    let dictionary = Dictionary::from_iter([
        ("update", Object::from(update_luafiles)),
        ("create_project", Object::from(create_project)),
    ]);

    Ok(dictionary)
}

