#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

# Find path to available PHP
if [[ -f "${vagrant_dir}/lib/php/php.exe" ]]; then
    php_executable="${vagrant_dir}/lib/php/php"
else
    php_executable="php"
fi
echo ${php_executable}
