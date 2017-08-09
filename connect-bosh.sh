#!/bin/bash
set -eu

secure_note="${1?'Provide the LastPass secure note name'}"

tmp_dir="$( mktemp -d /tmp/jumpbox-XXXXXX)"
lpass_note="$( lpass show --note "$secure_note" )"

creds() {
  local path=${1?'Path is required.'}
  bosh2 int <( echo "$lpass_note" ) --path /"$path"
}

# Download director CA Cert
creds bosh_ca_cert > "$tmp_dir/ca_cert.pem"
trap "{ rm -rf '$tmp_dir' }" EXIT

# Download jumpbox SSH key
creds jumpbox_ssh_key > "$tmp_dir/vcap.pem"
chmod 600 "$tmp_dir/vcap.pem"

# Download director client and client secret
export BOSH_CLIENT="$( creds bosh_client )"
export BOSH_CLIENT_SECRET="$( creds bosh_client_secret )"

jumpbox_host="$( creds jumpbox_host )"
jumpbox_user="$( creds jumpbox_ssh_user )"

export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT="$tmp_dir/ca_cert.pem"

# SSH tunnel through the jumpbox
ssh \
  -M -S "${tmp_dir}/tunnel-socket" \
  -i "$tmp_dir/vcap.pem" -fnNT -D 1080 "$jumpbox_user@$jumpbox_host"
trap "{ ssh -S '$tmp_dir/tunnel-socket' -O exit '$jumpbox_user@$jumpbox_host'; rm -rf '$tmp_dir'; }" EXIT
export BOSH_ALL_PROXY=socks5://localhost:1080

$SHELL --rcfile <(cat ~/.bashrc - <<'EOF'
prompt_command () {
    PS1="\n$(battery_char) $(clock_char) ${purple}\h ${yellow}→ ${yellow}jumpbox ${yellow}→ ${red}bosh_director ${reset_color}in ${green}\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
}
EOF
)
