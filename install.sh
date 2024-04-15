#! /bin/bash

cargo build --release
cp target/release/libspringtime_rs.so .
mv libspringtime_rs.so springtime_rs.so
