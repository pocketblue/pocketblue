#!/usr/bin/env bash

set -uexo pipefail

file_list=$1

download_file() {
    name=$1
    url=$2
    checksum=$3

    curl -L ${url} -o out/${name}
    echo "${checksum} out/${name}" | sha256sum --check
}

while IFS= read -r line; do
    args=($line)
    download_file ${args[0]} ${args[1]} ${args[2]}
done < "$file_list"
