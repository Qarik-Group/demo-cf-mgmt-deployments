#!/usr/bin/env bash
# transform cf-mgmt generated concourse to genesis repipe compatible version for multi-env setup
# usage : ./export-genesis-repipe.sh [env]
# it can be run multiple times to generate pipeline for many envs under same file

for var in "$@"
do
  echo "#PIPELINE# [START] Generating for $var"
  if grep -q "$var-config-repo" pipeline-genesis.yml; then
    echo "## Skipping $var"
    echo "$var env seems to be already added to the output pipeline."
    echo "##"
    continue
  fi
  # add to all jobs/resources `name:` the prefix of $env
  sed "/name: $var-/!s/name: /name: $var-/g" < pipeline.yml >> pipeline-$var-genesis.yml
  sed -i "s/((/((grab cf-mgmt.$var./g" pipeline-$var-genesis.yml
    # replace all config-repo for name/input/get
  sed -i "s/\<get: config-repo\>/get: $var-config-repo/g" pipeline-$var-genesis.yml
  sed -i "s/\<get: time-trigger\>/get: $var-time-trigger/g" pipeline-$var-genesis.yml
  cat <<BANNER >> pipeline-genesis.yml
#############################################
#### $var cf-mgmt pipeline configuration
#############################################
BANNER
  echo "#PIPELINE# [DONE] Generating for $var"

###TODO: Convert generated pipeline to genesis likeness
### - flatten jobs to tasks only
### - add input_mapping for each task
### - general replace names
  #echo "# Converting jobs to tasks for $var"
  #
  #sed -i "s/\jobs:(\s|.*)*//g" pipeline-$var-genesis.yml
#   cat <<JOB >> pipeline-$var-genesis.yml
# jobs:
# - name: $var-create-orgs
#   plan:
#   - get: $var-config-repo
#     trigger: true
# https://regex101.com/r/bTPfqF/1
# grep -zoP "task:[\S\s]+?(?:()[\S\s]+?)?CF_MGMT_COMMAND:[ a-z -]*" pipeline-dev-genesis.yml
# JOB
  cat pipeline-$var-genesis.yml >> pipeline-genesis.yml
  rm pipeline-$var-genesis.yml
done

