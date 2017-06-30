#!/bin/bash

jumpbox_ip=$1

if [[ -z "${jumpbox_ip}" ]]; then
  echo "Provide the jumpbox IP Address"
  exit 1
fi

# Download director CA Cert
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["director_ca_cert"]' \
  > /tmp/ca_cert.pem

# Download jumpbox SSH key
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["jumpbox_ssh_key"]' \
  > /tmp/vcap.pem
chmod 600 /tmp/vcap.pem

# Download director username and password
eval $(lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts "BOSH_CLIENT=#{data["director_admin_username"]}"; puts "BOSH_CLIENT_SECRET=#{data["director_admin_password"]}"')

cat > /tmp/bosh.env <<EOF
if [[ ! -x \$HOME/bosh2 ]]; then
  wget -O \$HOME/bosh2 https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.26-linux-amd64
  chmod +x \$HOME/bosh2
fi

alias bosh=\$HOME/bosh2
alias bosh2=\$HOME/bosh2

export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT=\$HOME/ca_cert.pem
export BOSH_CLIENT=$BOSH_CLIENT
export BOSH_CLIENT_SECRET=$BOSH_CLIENT_SECRET
bosh2 login
EOF

# Copy creds to jumpbox
scp -i /tmp/vcap.pem /tmp/vcap.pem /tmp/ca_cert.pem /tmp/bosh.env jumpbox@"${jumpbox_ip}":

echo "Remember to type in 'exec bash' and '. bosh.env'"
ssh -i /tmp/vcap.pem jumpbox@"${jumpbox_ip}"

rm /tmp/ca_cert.pem /tmp/vcap.pem /tmp/bosh.env
