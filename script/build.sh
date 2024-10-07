#!/usr/bin/env bash

current_dir=$1
dest_lib="$current_dir/libraries.lua"
dest_boot_version="$current_dir/spring_boot.lua"
dest_java_version="$current_dir/java_version.lua"
spring_url="https://start.spring.io"

# LIBRARIES
echo "return {" > $dest_lib 
curl -H 'Accept: application/json' $spring_url | jq -r '.dependencies.values[].values[] | "\t{ label = \"" + .name + "\", insertText = \"" + .id + ",\", versionRange = \"" + .versionRange + "\" },"' >> $dest_lib
echo "}" >> $dest_lib

# SPRING BOOT VERSION
curl -H 'Accept: application/json' $spring_url | jq -r '
  .bootVersion as $input |
  {
    selected: ($input.values | to_entries | map(select(.value.id == $input.default))[0].key + 1),
    values: ($input.values | map(.id | gsub("\\.RELEASE$"; "") | gsub("\\.BUILD-SNAPSHOT$"; "-SNAPSHOT") | gsub("\\.RC1$"; "-RC1")))
  } | "return { selected = \(.selected), values = { \"\(.values| join("\", \""))\" } }"
' > $dest_boot_version

# JAVA VERSION
curl -H 'Accept: application/json' $spring_url | jq -r '
  .javaVersion as $input |
  {
    selected: ($input.values | to_entries | map(select(.value.id == $input.default))[0].key + 1),
    values: ($input.values | map(.id ))
  } | "return { selected = \(.selected), values = { \(.values| join(", ")) } }"
' > $dest_java_version
