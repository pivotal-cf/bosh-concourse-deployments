#!/bin/bash

jumpbox_ip=$1

if [[ -z "${jumpbox_ip}" ]]; then
  echo "Provide the jumpbox IP Address"
  exit 1
fi

note="$(lpass show --note --sync=now "bosh-concourse-deployments gcp bosh-core")"
echo "$note" | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["bosh_ca_cert"]' > /tmp/ca_cert.pem
echo "$note"| ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["jumpbox_ssh_key"]' > /tmp/jumpbox.pem
echo "$note"| ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["director_ssh_key"]' > /tmp/director_jumpbox.pem
chmod 600 /tmp/jumpbox.pem

# Download director username and password
eval $(echo "$note" \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts "BOSH_ENVIRONMENT=#{data["bosh_environment"]}"; puts "BOSH_CLIENT=#{data["bosh_client_admin"]}"; puts "BOSH_CLIENT_SECRET=#{data["bosh_client_secret_admin"]}"')

cat > /tmp/bosh.env <<EOF
if [[ ! -x \$HOME/bosh ]]; then
  wget -O \$HOME/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-6.2.0-linux-amd64
  chmod +x \$HOME/bosh
fi

alias bosh=\$HOME/bosh
alias bosh=\$HOME/bosh

export BOSH_ENVIRONMENT=$BOSH_ENVIRONMENT
export BOSH_CA_CERT=\$HOME/ca_cert.pem
export BOSH_CLIENT=$BOSH_CLIENT
export BOSH_CLIENT_SECRET=$BOSH_CLIENT_SECRET
bosh login
EOF

# Copy creds to jumpbox
scp -i /tmp/jumpbox.pem /tmp/ca_cert.pem /tmp/bosh.env /tmp/director_jumpbox.pem bosh-core@"${jumpbox_ip}":

echo "Remember to type in 'exec bash' and '. bosh.env'"
# user found in bosh-concourse-deployments gcp bosh-core note, `jumpbox_ssh_user`
ssh -i /tmp/jumpbox.pem bosh-core@"${jumpbox_ip}"

rm /tmp/ca_cert.pem /tmp/jumpbox.pem /tmp/bosh.env /tmp/director_jumpbox.pem
