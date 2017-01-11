## BOSH Concourse Deployments

This repo holds the Concourse Pipelines, Jobs, and Tasks to setup a Concourse environment with:
* Terraform scripts to provision the environment
* Strict security groups: e.g. the DB port is only accessible from the ATC VM
* SSH traffic disabled by default: The SSH port is opened automatically by Concourse tasks to perform deployments and closed after.
* VMs configured with no public IPs: Only natbox and jumpbox have external IPs.

## Bootstrapping a Concourse Environment

#### Deploy Upgrader Concourse

We'll start by deploying a secondary "Upgrader" Concourse VM.
This Concourse will be used to setup the main Concourse environment on GCP as well as perform upgrades later on.
These steps assume you'll deploy the Upgrader to a local vSphere environment.
Alternatively you can `vagrant up` a Concourse instance on your workstation.

1. Create a versioned bucket to hold deployment state files:
  ```
  gcloud init
  gsutil mb gs://YOUR_BUCKET_NAME
  gsutil versioning set on gs://YOUR_BUCKET_NAME
  ```
1. Create a DNS record for the Upgrader VM pointing to a valid vSphere IP.
1. Register Concourse as an OAuth application with GitHub: https://github.com/settings/applications/new
  - Callback URL: `https://YOUR_EXTERNAL_URL/auth/github/callback`
1. Copy the contents of `./upgrader/upgrader.var.tmpl` to a LastPass note or some other safe location
1. Replace the placeholder fields with valid values for your environment.
1. Deploy the Upgrader VM:
  ```bash
  cd ./upgrader
  bosh create-env ./upgrader.yml -l <( lpass show --notes "bosh-concourse-upgrader-create-env" )
  git add ./upgrader-state.json
  git commit && git push
  ```
