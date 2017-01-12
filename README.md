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
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/vsphere-v5.1-worker-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/vcloud-v5.5-worker-state.json
  gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/worker/google-asia-worker-state.json
  ```

### Running Pipelines

1. Manually trigger `concourse/prepare-concourse-env` job.
1. Manually trigger `concourse/update-director` job.
1. Manually trigger `concourse/update-cloud-config` job.
1. Manually trigger `concourse/update-concourse` job.

#### Running Pipelines with Optional External Workers

If you have deployed optional external workers you must follow a slightly modified order:

1. Manually trigger `concourse/prepare-concourse-env` job.
1. Manually trigger `concourse/update-director` job.
1. Manually trigger `concourse/update-cloud-config` job.
1. Manually trigger `concourse-workers/prepare-asia-env` job.
  - the `concourse/update-concourse` job will place a file in `concourse-update-trigger` resource.
    This file is used to automatically trigger the external worker jobs across pipelines.
1. Manually trigger `concourse/update-concourse` job.

