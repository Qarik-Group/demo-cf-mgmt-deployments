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
  #todo: replace passed: arg
  #sed -i "s/\<>/"
    cat <<BANNER >> pipeline-genesis.yml
#############################################
#### $var cf-mgmt pipeline configuration
#############################################
BANNER
  cat pipeline-$var-genesis.yml >> pipeline-genesis.yml
  echo "#PIPELINE# [DONE] Generating for $var"
  echo "#GROUP# [START] Creating groups for $var"
  
cat<<GROUP >> pipeline-genesis.yml
#### group for $var
groups:
- ((append))
- name: $var-platform-management
  jobs:
$(grep "name: $var-" pipeline-genesis.yml | sed "s/- name: /  - /g" | sed -e "1,2d")
GROUP
  echo "#GROUP# [DONE] Adding jobs for $var"
  rm pipeline-$var-genesis.yml
done

