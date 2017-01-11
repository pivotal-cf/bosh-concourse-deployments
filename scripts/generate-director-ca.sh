#!/bin/bash

set -eu

deployments_dir="$( cd "$( dirname "$0" )" && cd .. && pwd )"

tmp_dir="${deployments_dir}/tmp"
mkdir -p "${tmp_dir}"

echo "Generating SSL CA Cert..."
yes "" | openssl req -x509 -newkey rsa:4096 -keyout "${tmp_dir}/director-ca.pem" -out "${tmp_dir}/director-ca.pub" -days 9999 -nodes > /dev/null 2>&1

echo "Your Director CA Key and Cert was generated at ${tmp_dir}/director-ca.pem and ${tmp_dir}/director-ca.pub"
