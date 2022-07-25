#!/usr/bin/env bash

if credhub f | grep cf_mgmt_client_secret; then
    echo "cf_mgmt_client_secret present!"
else
    echo "Can't find the cf_mgmt_client_secret"
    echo "Please check if you are authenticated in CredHub, from bosh-deployment run 'genesis do [env] credhub-login'"
    echo "Please check if cf-deployment was run with feature that creates this client [ex. ops/cf-mgmt-uaa-client.yml]"
    exit 1
fi

./cf-mgmt export-config\
  --system-domain=system.codex.starkandwayne.com\
  --user-id=cf_mgmt_client\
  --client-secret=$(credhub g -n /dev-bosh/dev-cf/cf_mgmt_client_secret | sed -n 's/value: //p')
