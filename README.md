## BOSH Concourse Deployments

This repo holds the Concourse Pipelines, Jobs, and Tasks to setup a Concourse environment with:
* Terraform scripts to provision the environment
* Strict security groups: e.g. the DB port is only accessible from the ATC VM
* SSH traffic disabled by default: The SSH port is opened automatically by Concourse tasks to perform deployments and closed after.
* VMs configured with no public IPs: Only natbox and jumpbox have external IPs.

## Bootstrapping a Concourse Environment

### Deploy Upgrader Concourse

We'll start by deploying a secondary "Upgrader" Concourse VM.
This Concourse will be used to setup the main Concourse environment on GCP as well as perform upgrades later on.
These steps assume you'll deploy the Upgrader to a local vSphere environment.
Alternatively you can `vagrant up` a Concourse instance on your workstation.

1. Create a DNS record for the Upgrader VM pointing to a valid vSphere IP.
1. Register Upgrader Concourse as an OAuth application with GitHub: https://github.com/settings/applications/new
  - Callback URL: `https://YOUR_UPGRADER_URL/auth/github/callback`
1. Copy the contents of `./upgrader/upgrader.vars.tmpl` to a LastPass note or some other safe location, filling in the appropriate values.
1. Deploy the Upgrader VM:

  ```bash
  cd ./upgrader
  bosh create-env ./upgrader.yml -l <( lpass show --notes "bosh-concourse-upgrader-create-env" )
  git add ./upgrader-state.json
  git commit && git push
  ```

### Set pipelines on upgrader vm

The upgrader vm must be configured with the pipelines that can deploy the
main Concourse deployment.

1. Read `./scripts/provision-gcloud-for-concourse.sh` to make sure you're not blindly running an untrusted bash script on your system
1. Set up the required variables and run the provision scripts:

  ```bash
  TERRAFORM_SERVICE_ACCOUNT_ID=concourse-deployments \
  DIRECTOR_SERVICE_ACCOUNT_ID=concourse-director \
  PROJECT_ID=my-gcp-project-id \
  CONCOURSE_BUCKET_NAME=concourse-deployments \
  ./scripts/provision-gcloud-for-concourse.sh
  ```
  - for debugging purposes you can also set `TRACE=true` to show all commands being run.
1. Generate a set of Google Cloud Storage Interoperability Keys as described [here](https://cloud.google.com/storage/docs/migrating#keys).
1. Create a GitHub access token to avoid rate limiting as described [here](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).
1. Register main Concourse as an OAuth application with GitHub: https://github.com/settings/applications/new
  - Callback URL: `https://YOUR_CONCOURSE_URL/auth/github/callback`
1. Generate the Director CA Cert by running `./scripts/generate-director-ca.sh`.
1. Generate the jumpbox ssh keys by running `./scripts/generate-jumpbox-ssh-key.sh`.
1. Add the jumpbox key as a project-wide SSH key with the username `vcap` as described [here](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys).
1. Copy the contents of `./ci/pipeline.vars.tmpl` to a LastPass note or some other safe location, filling in the appropriate values.
1. Log in using the fly cli to the newly deployed upgrader Concourse vm
1. Set the Concourse pipeline on the upgrader vm.

  ```bash
  fly -t upgrader sp -p concourse -c ~/workspace/bosh-concourse-deployments/ci/pipeline.yml -l <(lpass show note YOUR_LASTPASS_NOTE)
  ```

#### Additional Configuration for Optional External Workers

1. Configure external worker pipeline:
  The CPI Core team needs a few external workers and deploys them with this pipeline. If you'd like to deploy external workers
  yourself you can use this pipeline as an example.

  ```bash
  fly -t upgrader sp -p concourse-workers -c ~/workspace/bosh-concourse-deployments/ci/pipeline-cpi-workers.yml -l <(lpass show note YOUR_LASTPASS_NOTE)
  ```
1. Seed empty statefiles:

  ```bash
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/asia/natbox-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/asia/jumpbox-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/vsphere-v6.5-worker-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/vcloud-v5.5-worker-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/google-asia-worker-state.json
  ```

### Running Pipelines

1. Manually trigger `concourse/prepare-concourse-env` job.
1. Manually trigger `concourse/update-director` job.
1. Manually trigger `concourse/update-cloud-config` job.
1. Manually trigger `concourse/update-concourse` job.

**Warning** if completely repaving concourse and this results in an IP change
for the outbound requests from the VPC, then there are a few places that use
this IP address to break open holes for database or ssh connectivity.

At the time of this writing, two places were updated as a result of repaving:

1. Address for terraformed database instances present in main bosh pipeline.
1. 'Bosh lite' security group for bosh-agent integration tests for remote SSH

Removing the need for hardcoding would be ideal, but likely a lot of work. The
address should not change often, only when VPC-destructive concourse maintenance
occurs.

#### Running Pipelines with Optional External Workers

If you have deployed optional external workers you must follow a slightly modified order:

1. Manually trigger `concourse/prepare-concourse-env` job.
1. Manually trigger `concourse/update-director` job.
1. Manually trigger `concourse/update-cloud-config` job.
1. Manually trigger `concourse-workers/prepare-asia-env` job.
  - the `concourse/update-concourse` job will place a file in `concourse-update-trigger` resource.
    This file is used to automatically trigger the external worker jobs across pipelines.
1. Manually trigger `concourse/update-concourse` job. This should trigger the external worker
   jobs (i.e. you don't need to manually trigger the worker jobs).

### External Teams

Thanks to the distributed model of the CF Foundation many teams from many
companies can share this CI environment to run builds against their CPIs.
At the time of this writing, the CPI-only concourse is now destroyed, with the
majority of active CPIs building in the 'main' bosh concourse. External worker
setup is currently used for the Openstack CPI, as the director/worker lies
within a protected egress-only openstack env.

#### Creating a team on the ATC (Concourse Administrator)

In this example, we are adding a new team 'DigitalOcean CPI'

The DigitalOcean CPI team has provided following:

- a worker public key
- a GitHub organization
- a GitHub team within that organization that will be able to authenticate against the Concourse environment.
- a Concourse team name, no space, no special characters, all lowercase, (e.g. "digitalocean")

The BOSH CPI team does the following:

1. Shares the TSA host public key (search for `concourse_tsa_public_key` in LastPass)
  with the DigitalOcean CPI team (e.g. "ssh-rsa AAAAB3NTSAHostPublicKey...")
1. Add the worker public key entry to the list under [`concourse_teams`](https://github.com/pivotal-cf/bosh-concourse-deployments/blob/d87f8b7134b407d78bfcda29dcd721e0ade746bd/ci/pipeline.vars.tmpl#L54-L56) on the secure note saved on LassPass.
    Example:

```json
[{"name": "digitalocean", "github_team":  "DigitalOcean/BOSH CPI", "worker_public_key": "ssh-rsa AAAAB3DigitalOceanWorker..."}]
```
1. Trigger the [update-concourse](https://bosh-upgrader.ci.cf-app.com/teams/main/pipelines/concourse/jobs/update-concourse/) job, making sure there are no running jobs first.

Let the DigitalOcean CPI team know when the deploy has finished so that they can
rock.

#### Creating external worker manifest (Team member)

The BOSH CPI team has provided following:

- TSA host public key
- TSA URL (e.g. https://bosh-cpi.ci.cf-app.com)

Do the following:

1. Generate a key for your worker. The following command will create a keypair; don't use passphrase:
```
ssh-keygen  -N '' -b 4096 -f /tmp/openstack-cpi-worker -C team_name
```
1. Transmit the _public_ portion to the BOSH CPI team (e.g. "ssh-rsa AAAAB3DigitalOceanWorker...").
1. Let the BOSH CPI team know your GitHub organization (e.g.
"DigitalOcean") and team handle (e.g. "DigitalOcean CPI").
1. Pick a display name for your team and let the BOSH CPI team know. (e.g. "digitalocean")
1. Create the manifest for your worker and make sure to set the following properties:

  ```
  team: ((worker_team_name))
  tsa:
    host: ((concourse_tsa_hostname))
    host_public_key: ((concourse_tsa_public_key))
    private_key: ((worker_private_key))
  ```

  * worker_team_name, e.g. "digitalocean". This is the team name provided to BOSH CPI
  * concourse_tsa_hostname, e.g. https://bosh-cpi.ci.cf-app.com, provided by BOSH CPI
  * host_public_key: e.g. "ssh-rsa AAAAB3NTSAHostPublicKey...", provided by BOSH CPI
  * worker_private_key: the private key generated for the worker

You can find a sample of a worker manifest [here](https://github.com/pivotal-cf/bosh-concourse-deployments/blob/master/vsphere-v6.5/worker.yml).

After deploying the worker, authenticate with Concourse and confirm worker has registered:

1. Browse to the Concourse URL and download the `fly` client
1. Log into Concourse: `fly -t cpi login -c https://bosh-cpi.ci.cf-app.com -n digitalocean`
1. Confirm worker has registered: `fly -t cpi workers`

### Updating Trusted CIDRs for access (workers and humans)

1. Ensure lastpass note is updated with the CIDRs. Look in the `bosh-concourse-deployments gcp bosh-core` note for the CIDRs and their sources.
1. Run `configure-shared` to pick up any lastpass note changes
1. Start a `re-terraform` job in the shared environment pipeline to refresh the firewall rules.

### Troubleshooting

Refer to the _Troubleshooting_ document under [docs/](`docs/`).

## Figures

### GCloud Network Topology
![gcloud network topology](https://docs.google.com/drawings/d/1TbnPOjp27vpwxI5hJi2ateVXEU0_2KQf6RbtMmLUyZ0/pub?w=925&h=1172)
