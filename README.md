# demo-cf-mgmt-deployments
Demo repository that holds config and CI configuration for an CloudFoundry deployment that uses cf-mgmt to configure itself.

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
            resource_ids: none
            authorized-grant-types: client_credentials,refresh_token
            authorities: routing.router_groups.read,scim.write,scim.read,cloud_controller.admin
            autoapprove:
            scope: routing.router_groups.read,scim.write,scim.read,cloud_controller.admin
            secret: ((cf_mgmt_client_secret))

variables:
- name: cf_mgmt_client_secret
  type: password
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

From this repository root run:
```bash
./export-config.sh
```
export-config documentation: https://github.com/vmware-tanzu-labs/cf-mgmt/blob/main/docs/export-config/README.md

This should create a new directory called `config` at the top level. 

#### Concourse Pipeline generation
With the `config/` dir generated let's now run CI generation:
```bash
./cf-mgmt-config generate-concourse-pipeline
```
This should create two things:
- a dir named `ci`
- a yml file named `pipeline.yml`

What it did was it generated a multiple Concourse `jobs` that all call the same `task` which just executes `cf-mgmt` with correct input of parameters regarding what resource needs to be modified on CloudFoundry side.

**Add config/vars.yml to .gitignore**

It should not be pushed to the remote repository (or it can if you don't have plain text passwords in it ;-) )

Example `config/vars.yml`
```yaml
# your git repo uri
git_repo_uri: "https://github.com/starkandwayne/demo-cf-mgmt-deployments"
git_repo_branch: main
# your cf system domain
system_domain: "system.codex.starkandwayne.com"
# user account with permission to create orgs/spaces
user_id: "cf_mgmt_client"
# DEPRECATED - Use client_secret - password of user account with permission to create orgs/spaces
password: ""
# client secret for uaa for user_id
client_secret: "[read it via \"credhub g -n /dev-bosh/dev-cf/cf_mgmt_client_secret | sed -n 's/value: //p'\""

# logging level for cf-mgmt commands in the pipeline
log_level: INFO
# time interval to trigger update/delete jobs on
time-trigger: 15m

# configuration directory
config_dir: config

# allow specifying ldap server in pipeline vs in ldap.yml only needed if using LDAP
ldap_server: ""

# allow specifying ldap bind user in pipeline vs in ldap.yml only needed if using LDAP
ldap_user: ""

# password to bind to ldap - only needed if using LDAP
ldap_password: ""
```