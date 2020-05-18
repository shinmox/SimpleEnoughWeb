#!/bin/bash

THIS_DIRECTORY=$( cd "$(dirname "$0")" ; pwd -P )
PROJECT_ROOT="${THIS_DIRECTORY}/../../.."
DEPLOYMENT_PATH_FROM_PROJECT_ROOT="deploy"
DEPLOYMENT_DIRECTORY="${PROJECT_ROOT}/${DEPLOYMENT_PATH_FROM_PROJECT_ROOT}"
. "${DEPLOYMENT_DIRECTORY}/lib/common.sh"

#set -euo pipefail

(
    cd "${PROJECT_ROOT}/ui"
    npm ci
    npm run-script build
)
