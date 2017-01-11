#!/bin/bash

set -eu

deployments_dir="$( cd "$( dirname "$0" )" && cd .. && pwd )"

tmp_dir="${deployments_dir}/tmp"
mkdir -p "${tmp_dir}"

echo "Generating SSH Key..."
ssh-keygen -f "${tmp_dir}/jumpbox.pem" -N '' -C vcap
mv ${tmp_dir}/jumpbox{.pem.pub,.pub}

echo "Your Jumpbox SSH key was generated at ${tmp_dir}/jumpbox.pem"
