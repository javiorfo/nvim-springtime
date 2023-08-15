use nvim_oxi as oxi;

#[oxi::module]
fn springtime() -> oxi::Result<i32> {
    Ok(42)
}
