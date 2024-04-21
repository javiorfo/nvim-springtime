#! /bin/bash

ROOT=$1

(cd $ROOT && cargo build --release --quiet)

if [ $? -ne 0 ]; then
    exit 1
fi

cp $ROOT/target/release/libspringtime_rs.so $ROOT
mv $ROOT/libspringtime_rs.so $ROOT/springtime_rs.so
mv $ROOT/springtime_rs.so $ROOT/lua/
