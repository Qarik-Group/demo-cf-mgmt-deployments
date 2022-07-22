# demo-cf-mgmt-deployments
Demo repository that holds config for cf-mgmt deployments

## Setup
#### Setup cf-mgmt UAA client, put the content into your cf-genesis-kit/ops/*.yml
```yaml
instance_groups:
- name: uaa
  jobs:
  - name: uaa
    properties:
      uaa:
        clients:
          cf_mgmt_client:
            access-token-validity: 1200
            authorized-grant-types: client_credentials,refresh_token
            authorities: cloud_controller.admin
            autoapprove: true
            override: true
            redirect-uri: https://uaa.((system_domain))/login
            refresh-token-validity: 2592000
            scope: cloud_controller.admin,scim.read,scim.write,routing.router_groups.read
            secret: ((cf_mgmt_client_secret))

variables:
- name: cf_mgmt_client_secret
  type: password

exodus:
  cf_mgmt_client:             cf_mgmt_client
  cf_mgmt_client_secret:      (( grab instance_groups.uaa.jobs.uaa.properties.uaa.clients.cf-mgmt-client.secret ))
```

#### Get cf-mgmt CLI tools:
```bash
wget https://github.com/vmware-tanzu-labs/cf-mgmt/releases/download/v1.0.52/cf-mgmt-linux
wget https://github.com/vmware-tanzu-labs/cf-mgmt/releases/download/v1.0.52/cf-mgmt-config-linux

mv cf-mgmt-linux cf-mgmt
mv cf-mgmt-config-linux cf-mgmt-config
```
You may want to move those binaries somewhere else and alias them under you bash/zsh/any-sh profiles, but usually the range of use is unitary.

#### Export configuration, or initialise new one.
Initialisation should happen only if you are connecting cf-mgmt configuration to a brand new CF deployment. If there are Orgs/Spaces/Quotas/ASG's etc already setup you may want to export it instead of overriding.

```bash

```
export-config documentation: https://github.com/vmware-tanzu-labs/cf-mgmt/blob/main/docs/export-config/README.md

