#!/bin/bash

set -eu

: ${TERRAFORM_SERVICE_ACCOUNT_ID:?}
: ${DIRECTOR_SERVICE_ACCOUNT_ID:?}
: ${PROJECT_ID:?}
: ${CONCOURSE_BUCKET_NAME:?}
: ${TRACE:=false}

if [ $TRACE = true ]; then
  set -x
fi

deployments_dir="$( cd "$( dirname "$0" )" && cd .. && pwd )"

tmp_dir="${deployments_dir}/tmp"
mkdir -p "${tmp_dir}"

terraform_service_account_email="${TERRAFORM_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
director_service_account_email="${DIRECTOR_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Setting up gcloud"
gcloud init

echo "Creating bucket ${CONCOURSE_BUCKET_NAME}"
gsutil mb "gs://${CONCOURSE_BUCKET_NAME}"
gsutil versioning set on "gs://${CONCOURSE_BUCKET_NAME}"

echo "Creating Service Account ${terraform_service_account_email}..."
gcloud iam service-accounts create "${TERRAFORM_SERVICE_ACCOUNT_ID}"
gcloud iam service-accounts keys create "${tmp_dir}/${TERRAFORM_SERVICE_ACCOUNT_ID}.key.json" \
  --iam-account "${terraform_service_account_email}"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${terraform_service_account_email}" \
  --role roles/compute.instanceAdmin \
  --role roles/compute.networkAdmin \
  --role roles/compute.storageAdmin \
  --role roles/compute.securityAdmin \
  --role roles/storage.admin \
  --role roles/iam.serviceAccountActor

echo "Creating Service Account ${director_service_account_email}..."
gcloud iam service-accounts create "${DIRECTOR_SERVICE_ACCOUNT_ID}"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member "serviceAccount:${director_service_account_email}" \
  --role roles/compute.instanceAdmin \
  --role roles/compute.networkAdmin \
  --role roles/compute.storageAdmin \
  --role roles/storage.admin \
  --role roles/iam.serviceAccountActor

echo "Success!"
echo "Your Terraform service account key was downloaded to ${tmp_dir}/${TERRAFORM_SERVICE_ACCOUNT_ID}.key.json"
