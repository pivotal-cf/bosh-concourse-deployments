## BOSH Concourse Deployments

This repo holds the Concourse Pipelines, Jobs, and Tasks for the Pivotal's BOSH
project's stemcell builder.

### Developer Notes

The bucket which holds to BOSH Director's state must be created manually
(until Terraform supports the creation of versioned buckets under google).

* name: bosh-gcp-concourse-deployment
* Default storage class: Multi-Regional
* Location: US
* enable versioning:
```
gsutil versioning set on gs://bosh-gcp-concourse-deployment
```

### Creating a new Concourse team

1. Register Concourse as an OAuth application: https://github.com/settings/applications/new
1. Create the team:
```bash
fly set-team -n bosh-cpi \
    --github-auth-client-id $CLIENT_ID \
    --github-auth-client-secret $CLIENT_SECRET \
    --github-auth-team "cloudfoundry/CF BOSH CPI"
```
