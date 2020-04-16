### Troubleshooting
To enable debugging with the `bosh` cli, perform the following steps:

1. Open up the ssh port to our jumpbox for 30 minutes by triggering the
   [concourse/open-ssh-for-30m](https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/shared-environment/jobs/open-ssh-for-30m/) job.
1. Wait for confirmation that the SSH port is open.
1. Use the `connect-bosh.sh` (or `connect-bosh-core.sh`) script to establish a connection and start the tunnel.
   * If you see `Operation timed out`, it means that we need to fire up
   our [concourse/open-ssh-for-30m](https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/shared-environment/jobs/open-ssh-for-30m/) Concourse job to allow us to ssh-in again.
   * `ssh-jumpbox <ip>` will also work and may be a better maintained script
   * Note: If you're running this from a non-bosh computer you need to ssh or tunnel through a trusted ip - the sf and toronto bosh computers should be fine - see `jumpbox_trusted_cidrs` in the lpass note `bosh-concourse-deployments gcp bosh-core`
1. You should now be targeted and can use `bosh` commands like normal.


#### Initial Configuration of Jumpbox

You only need to do this once, unless you redeploy the jumpbox.

1. Download the BOSH director's CA certificate, which we stored in LastPass:

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline-director \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["director_ca_cert"]' \
  > /tmp/ca_cert.pem
```
1. Open up ssh to the jumpbox for 30 minutes by kicking off the
   Concourse job: https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/shared-environment/jobs/open-ssh-for-30m/.
1. Examine the output of the _wait-for-ssh_ task to determine the IP
   address of the jumpbox:

```
Your jumpbox address is '104.198.xx.yy'.
```
1. Now we need to find our private key.
   The private key will be in our credential file, which we stored in LastPass,
   in the secure note "secret-lastpass-note".

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline-director \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["jumpbox_ssh_key"]' \
  > /tmp/vcap.pem
chmod 600 /tmp/vcap.pem
```
1. Print out the BOSH director user and password; you'll need this later to
   log in:

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline-director \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["director_admin_username"]; puts data["director_admin_password"]'
```
1. Copy the ca_cert and the vcap key to the jumpbox (the cert needed to execute BOSH commands; the key is needed to ssh to VMs):

```
scp -i /tmp/vcap.pem /tmp/vcap.pem /tmp/ca_cert.pem jumpbox@104.198.xx.yy:
```
1. ssh into the jumpbox:

```
ssh -i /tmp/vcap.pem jumpbox@104.198.xx.yy
```
1. Install BOSH CLI (if it's not already installed):

```
curl -L https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.147-linux-amd64 -o bosh
chmod +x bosh
sudo mv bosh /usr/local/bin/bosh
```
1. Log into the director:

```
export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT=$PWD/ca_cert.pem
export BOSH_CLIENT=admin # whatever the director admin user is
export BOSH_CLIENT_SECRET=blahblah # whatever the director admin password is
bosh login
bosh alias-env bosh
```
1. Install tmux

```
sudo apt-get install -y tmux
```
