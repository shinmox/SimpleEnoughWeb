#!/bin/bash

THIS_DIRECTORY=$( cd "$(dirname "$0")" ; pwd -P )
PROJECT_ROOT="${THIS_DIRECTORY}/../../.."
DEPLOYMENT_PATH_FROM_PROJECT_ROOT="deploy"
DEPLOYMENT_DIRECTORY="${PROJECT_ROOT}/${DEPLOYMENT_PATH_FROM_PROJECT_ROOT}"
. "${DEPLOYMENT_DIRECTORY}/lib/common.sh"

set -euo pipefail

(
    cd "${PROJECT_ROOT}/ui"

    ipAddress=$(docker inspect `docker ps -f label=kind=web -q`| jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress')
    echo_lightgreen "Your application will be accessible at:"
    echo http://${ipAddress}:3000

    echo
    echo_lightgreen "Start dev server"
    ls -la
    COLOR=1 yarn start | cat
)
