extern crate neovim_lib;

use neovim_lib::{ Neovim, NeovimApi, Session };

fn main() {
    let session = Session::new_parent().unwrap();
    let nvim = Neovim::new(session);
}
