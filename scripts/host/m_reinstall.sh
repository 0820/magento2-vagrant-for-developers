#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/output_functions.sh"

cd "${vagrant_dir}"
vagrant ssh -c "bash /vagrant/scripts/guest/m-reinstall" 2> >(logError)
