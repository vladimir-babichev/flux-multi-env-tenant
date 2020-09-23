#!/usr/bin/env bash

set -o errexit

: ${1?"Usage: $0 <TEAM NAME>"}

TEAM_NAME=$1
TEMPLATE="team1"
ENV_NAMES="dev stage"
ENV_TEMPLATE="dev"
REPO_ROOT=$(git rev-parse --show-toplevel)
TEAM_DIR="${REPO_ROOT}/cluster/${TEAM_NAME}/"

mkdir -p ${TEAM_DIR}

cp -r "${REPO_ROOT}/template/cluster/${TEMPLATE}/." ${TEAM_DIR}

for f in ${TEAM_DIR}*.yaml
do
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/$TEMPLATE/$TEAM_NAME/g" ${f}
  else
    sed -i "s/$TEMPLATE/$TEAM_NAME/g" ${f}
  fi
done

echo "${TEAM_NAME} created at ${TEAM_DIR}"
echo "  - ./${TEAM_NAME}/" >> "${REPO_ROOT}/cluster/kustomization.yaml"
echo "${TEAM_NAME} added to ${REPO_ROOT}/cluster/kustomization.yaml"

for env_name in $ENV_NAMES; do
  ENV_DIR="${REPO_ROOT}/environment/${env_name}/${TEAM_NAME}/"
  mkdir -p ${ENV_DIR}
  cp -r "${REPO_ROOT}/template/environment/${ENV_TEMPLATE}/${TEMPLATE}/." ${ENV_DIR}

  for f in ${ENV_DIR}*.yaml
  do
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/$TEMPLATE/$TEAM_NAME/g; s/$ENV_TEMPLATE/$env_name/g" ${f}
    else
      sed -i "s/$TEMPLATE/$TEAM_NAME/g; s/$ENV_TEMPLATE/$env_name/g" ${f}
    fi
  done

  echo "${env_name} created at ${ENV_DIR}"
  echo "  - ./${TEAM_NAME}/" >> "${REPO_ROOT}/environment/${env_name}/kustomization.yaml"
  echo "${TEAM_NAME} added to ${REPO_ROOT}/environment/${env_name}/kustomization.yaml"
done
