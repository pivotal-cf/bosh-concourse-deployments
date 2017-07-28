#!/bin/bash
set -eu

jumpbox_ip=$1
if [[ -z "${jumpbox_ip}" ]]; then
  echo "Provide the jumpbox IP Address"
  exit 1
fi

BOSH_CONCOURSE_UPGRADER_SECURE_NOTE=bosh-concourse-upgrader-cpi-pipeline

tmp_dir="$( mktemp -d /tmp/jumpbox-XXXXXX)"
# Download director CA Cert
bosh2 int \
  <( lpass show --note "$BOSH_CONCOURSE_UPGRADER_SECURE_NOTE" ) \
  --path /director_ca_cert \
  > "$tmp_dir/ca_cert.pem"
trap "{ rm -rf '$tmp_dir' }" EXIT

# Download jumpbox SSH key
bosh2 int \
  <( lpass show --note "$BOSH_CONCOURSE_UPGRADER_SECURE_NOTE" ) \
  --path /jumpbox_ssh_key \
  > "$tmp_dir/vcap.pem"
chmod 600 "$tmp_dir/vcap.pem"

# Download director username and password
export BOSH_CLIENT="$( bosh2 int \
  <( lpass show --note "$BOSH_CONCOURSE_UPGRADER_SECURE_NOTE" ) \
  --path /director_admin_username )"
export BOSH_CLIENT_SECRET="$( bosh2 int \
  <( lpass show --note "$BOSH_CONCOURSE_UPGRADER_SECURE_NOTE" ) \
  --path /director_admin_password )"

export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT="$tmp_dir/ca_cert.pem"
export BOSH_GW_USER=jumpbox
export BOSH_GW_HOST=10.0.0.6
export BOSH_GW_PRIVATE_KEY="$tmp_dir/vcap.pem"

# SSH tunnel through the jumpbox
ssh \
  -M -S "${tmp_dir}/tunnel-socket" \
  -i "$tmp_dir/vcap.pem" -fnNT -D 1080 jumpbox@"$jumpbox_ip"
trap "{ ssh -S '$tmp_dir/tunnel-socket' -O exit jumpbox@$jumpbox_ip; rm -rf '$tmp_dir'; }" EXIT
export BOSH_ALL_PROXY=socks5://localhost:1080

$SHELL
