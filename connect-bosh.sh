#!/bin/bash -eu
lpass_note="$( set -eu ; lpass show --note bosh-concourse-upgrader-cpi-pipeline-director )"

creds() {
  local path=${1?'Path is required.'}
  bosh int <( echo "$lpass_note" ) --path /"$path"
}

jumpbox_host="$( set -eu ; creds jumpbox_host )"
jumpbox_user="$( set -eu ; creds jumpbox_ssh_user )"

tmp_dir="$( mktemp -d /tmp/jumpbox-XXXXXX)"

cleanup() {
  [[ ! -e "$tmp_dir/tunnel-socket" ]] || ssh -S "$tmp_dir/tunnel-socket" -O exit "$jumpbox_user@$jumpbox_host"
  rm -rf "$tmp_dir"
}

trap cleanup EXIT

# director CA Cert
creds bosh_ca_cert > "$tmp_dir/ca_cert.pem"
# jumpbox SSH key
creds jumpbox_ssh_key > "$tmp_dir/vcap.pem"
chmod 600 "$tmp_dir/vcap.pem"
# director client and client secret
export BOSH_CLIENT="$( creds bosh_client )"
export BOSH_CLIENT_SECRET="$( creds bosh_client_secret )"
export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT="$tmp_dir/ca_cert.pem"

# SSH tunnel through the jumpbox
ssh \
  -M -S "${tmp_dir}/tunnel-socket" \
  -i "$tmp_dir/vcap.pem" -fnNT -D 1080 "$jumpbox_user@$jumpbox_host"
export BOSH_ALL_PROXY=socks5://localhost:1080

$SHELL --rcfile <(cat ~/.bashrc - <<'EOF'
prompt_command () {
    PS1="\n$(battery_char) $(clock_char) ${purple}\h ${yellow}→ ${yellow}jumpbox ${yellow}→ ${red}bosh_director ${reset_color}in ${green}\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
}
EOF
)
