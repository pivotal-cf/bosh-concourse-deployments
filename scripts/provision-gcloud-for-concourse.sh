#!/bin/bash

set -eu

: ${TERRAFORM_SERVICE_ACCOUNT_ID:?}
: ${DIRECTOR_SERVICE_ACCOUNT_ID:?}
: ${PROJECT_ID:?}
: ${CONCOURSE_BUCKET_NAME:?}
${TRACE:=false}

if [[ $TRACE = true ]]; then
  set -x
fi

deployments_dir="$( cd "$( dirname "$0" )" && cd .. && pwd )"

tmp_dir="${deployments_dir}/tmp"
mkdir -p "${tmp_dir}"

terraform_service_account_email="${TERRAFORM_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
director_service_account_email="${DIRECTOR_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

function add_role() {
  service_account_email=$1
  role=$2

  echo "${role}"

  gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${service_account_email}" \
    --role "${role}"
}

echo "Setting up gcloud"
gcloud init

echo "Creating bucket ${CONCOURSE_BUCKET_NAME}..."
gsutil mb "gs://${CONCOURSE_BUCKET_NAME}"
gsutil versioning set on "gs://${CONCOURSE_BUCKET_NAME}"

echo "Seeding bucket with empty state files..."
gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/concourse/natbox-state.json
gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/concourse/jumpbox-state.json
gsutil cp -n <( echo '{}' ) gs://${CONCOURSE_BUCKET_NAME}/director/bosh-state.json

echo "Creating Service Account ${terraform_service_account_email}..."
gcloud iam service-accounts create "${TERRAFORM_SERVICE_ACCOUNT_ID}"
gcloud iam service-accounts keys create "${tmp_dir}/${TERRAFORM_SERVICE_ACCOUNT_ID}.key.json" \
  --iam-account "${terraform_service_account_email}"

echo "Adding roles to ${terraform_service_account_email}..."
add_role "${terraform_service_account_email}" roles/compute.instanceAdmin
add_role "${terraform_service_account_email}" roles/compute.networkAdmin
add_role "${terraform_service_account_email}" roles/compute.storageAdmin
add_role "${terraform_service_account_email}" roles/compute.securityAdmin
add_role "${terraform_service_account_email}" roles/storage.admin
add_role "${terraform_service_account_email}" roles/iam.serviceAccountActor
echo ""

echo "Creating Service Account ${director_service_account_email}..."
gcloud iam service-accounts create "${DIRECTOR_SERVICE_ACCOUNT_ID}"

echo "Adding roles to ${director_service_account_email}..."
add_role "${director_service_account_email}" roles/compute.instanceAdmin
add_role "${director_service_account_email}" roles/compute.networkAdmin
add_role "${director_service_account_email}" roles/compute.storageAdmin
add_role "${director_service_account_email}" roles/storage.admin
add_role "${director_service_account_email}" roles/iam.serviceAccountActor
echo ""

echo "Success!"
echo "Your Terraform service account key was downloaded to ${tmp_dir}/${TERRAFORM_SERVICE_ACCOUNT_ID}.key.json"
