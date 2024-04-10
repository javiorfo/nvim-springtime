#! /bin/bash

cargo build --release
cp target/release/libspringtime_rs.so .
mv libspringtime_rs.so springtime_rs.so
cp springtime_rs.so ~/.local/share/nvim/lazy/nvim-springtime/lua/
rm springtime_rs.so
