### Troubleshooting

In this example, we need to troubleshoot why a worker is not registered
with the ATC. We need to log into the ATC.

1. Open up the ssh port to our jumpbox for 30 minutes by triggering the
   https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/concourse/jobs/open-ssh-for-30m job.
1. Examine the output of the _wait-for-ssh_ task to determine the IP
   address of the jumpbox:

```
Your jumpbox address is '104.198.xx.yy'.
```
1. We have our natIP (104.198.xx.yy). Now we need to find our private key.
   The private key will be in our credential file, which we stored in LastPass,
   in the secure note "secret-lastpass-note".

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["jumpbox_ssh_key"]' \
  > /tmp/vcap.pem
chmod 600 /tmp/vcap.pem
```
6. Now we can connect to our jumpbox as the user `vcap`:

```
ssh -i /tmp/vcap.pem jumpbox@104.198.xx.yy
```
7. If you see `Operation timed out`, it means that we need to fire up
   our https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/concourse/jobs/open-ssh-for-30m Concourse job to allow us to ssh-in again.
8. Use `bosh ssh` to talk to the director (the jumpbox cannot directly ssh to the director) (use your deployment name; don't use `concourse-cpi`):

```
tmux attach || tmux # attach to an existing tmux session if possible
export BOSH_ENVIRONMENT=10.0.0.6
export BOSH_CA_CERT=$PWD/ca_cert.pem
bosh deployments # find your deployment
bosh instances -d concourse-cpi # or whatever your deployment is
bosh ssh -d concourse-cpi \
  concourse_cpi \
  --gw-user=jumpbox \
  --gw-host=10.0.0.6 \
  --gw-private-key=$PWD/vcap.pem
```

#### Initial Configuration of Jumpbox

You only need to do this once, unless you redeploy the jumpbox.

1. Download the BOSH director's CA certificate, which we stored in LastPass:

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["director_ca_cert"]' \
  > /tmp/ca_cert.pem
```
1. Open up ssh to the jumpbox for 30 minutes by kicking off the
   Concourse job: https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/concourse/jobs/open-ssh-for-30m.
1. Examine the output of the _wait-for-ssh_ task to determine the IP
   address of the jumpbox:

```
Your jumpbox address is '104.198.xx.yy'.
```
1. Now we need to find our private key.
   The private key will be in our credential file, which we stored in LastPass,
   in the secure note "secret-lastpass-note".

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
  | ruby -r yaml -e 'data = YAML::load(STDIN.read); puts data["jumpbox_ssh_key"]' \
  > /tmp/vcap.pem
chmod 600 /tmp/vcap.pem
```
1. Print out the BOSH director user and password; you'll need this later to
   log in:

```
lpass show --note bosh-concourse-upgrader-cpi-pipeline \
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
