#!/bin/bash
set -e

echo "If the following call to google storage APIs fails, try 'gcloud auth login'"
NIMBUS_VARS=$(gsutil cat gs://bosh-core-concourse-deployment/nimbus-vcenter-vars.yml)
IP=$(yq read <(echo "$NIMBUS_VARS") "vcenter_ip")
USER=$(yq read <(echo "$NIMBUS_VARS") "vcenter_user")
PASS=$(yq read <(echo "$NIMBUS_VARS") "vcenter_password")
echo "Success!"
echo ""
echo "You may need to type 'thisisunsafe', multiple times, to get through the browser security warning"
echo "The username is '$USER', password is '$PASS'"
echo ""
echo "Here's the URL to the vcenter UI: https://$IP/ui"
