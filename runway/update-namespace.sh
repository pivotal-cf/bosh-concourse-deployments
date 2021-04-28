#!/bin/bash

if ! command -v runctl &> /dev/null
then
    echo "please install the runway cli first:"
    echo "https://gitlab.eng.vmware.com/devtools/runway/cli/runctl/tree/master#installation"
    exit 1
fi


config=~/.runway/config.yml
if [ ! -f "$config" ]; then
    echo "configuring runway cli creating: $config"
    echo "please enter your vmware LDAP credentials"
    read -p "username: " username
    read -s -p "password: " password
    mkdir -p ~/.runway
    echo "auth: $(echo -n "${username}:${password}" | base64)" > $config
    echo ""
fi

echo "Updating namespace"
# bosh-core namespace has id 719
runctl ns update --file access.json
