#!/usr/bin/env bash

vagrant_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.."; pwd)

source "${vagrant_dir}/scripts/functions.sh"

magento_ce_dir="${vagrant_dir}/magento2ce"
magento_ee_dir="${magento_ce_dir}/magento2ee"
magento_ce_sample_data_dir="${magento_ce_dir}/magento2ce-sample-data"
magento_ee_sample_data_dir="${magento_ce_dir}/magento2ee-sample-data"
php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"
install_sample_data=$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_install_sample_data")


install_ee=0
if [[ -f "${magento_ce_dir}/app/etc/enterprise/di.xml" ]]; then
    install_ee=1
fi

# As a precondition, disable CE sample data
if [[ -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
    ${php_executable} -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=unlink --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ce_sample_data_dir}"
    echo "CE Sample data disabled"
fi
# As a precondition, disable EE sample data
if [[ -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
    "${php_executable}" -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=unlink --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ee_sample_data_dir}"
    echo "EE Sample data disabled"
fi

if [[ ${install_ee} -eq 1 ]]; then
    "${php_executable}" -f "${magento_ee_dir}/dev/tools/build-ee.php" -- --command=link --ee-source="${magento_ee_dir}" --ce-source="${magento_ce_dir}"
fi

if [[ ${install_sample_data} -eq 1 ]]; then
    # Installing CE or EE, in both cases CE sample data should be linked
    if [[ ! -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
        # Sample data not available and should be enabled
        echo "CE Sample data repository is not available. Recreate project using \"init_project.sh -fc\", which will delete Magento code base and recreate project from scratch. Or clone sample data to <project_dir>/magento2ce/magento2ce-sample-data."
        exit 0
    else
        # Sample data available and should be enabled
        echo "CE Sample data enabled"
        "${php_executable}" -f "${magento_ce_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=link --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ce_sample_data_dir}"
    fi

    if [[ ${install_ee} -eq 1 ]]; then
        # Installing EE
        if [[ ! -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" ]]; then
            # Sample data not available and should be enabled
            echo "EE Sample data repository is not available. Recreate project using \"init_project.sh -fc\", which will delete Magento code base and recreate project from scratch. Or clone sample data to <project_dir>/magento2ce/magento2ee-sample-data."
            exit 0
        else
            # Sample data available and should be enabled
            echo "EE Sample data enabled"
            "${php_executable}" -f "${magento_ee_sample_data_dir}/dev/tools/build-sample-data.php" -- --command=link --ce-source="${magento_ce_dir}" --sample-data-source="${magento_ee_sample_data_dir}"
        fi
    fi
fi
