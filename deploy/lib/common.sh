#!/bin/bash

# FILE SYSTEM
RESOURCE_PATH="${DEPLOYMENT_DIRECTORY}/kinds"
function get_deployment_kind_path {
    echo "${RESOURCE_PATH}/${DEPLOYMENT_KIND}"
}
function get_kind_commands {
    echo $(
        ls "${RESOURCE_PATH}/${1}" \
        | grep "\.sh" \
        | sed "s|\.sh||g"
    )
}

# COLORS
RED='\033[0;31m'
CYAN='\033[0;36m'
LIGHT_GREEN='\033[0;92m'
LIGHT_YELLOW='\033[0;93m'
LIGHT_MAGENTO='\033[0;95m'
NO_COLOUR='\033[0m'
function echo_cyan {
    if [[ "${QUIET}" == 0 ]]; then
        echo -e "${CYAN}${@}${NO_COLOUR}";
    fi
}
function echo_red { echo -e "${RED}${@}${NO_COLOUR}"; }
function echo_lightgreen {
    if [[ "${QUIET}" == 0 ]]; then
        echo -e "${LIGHT_GREEN}${@}${NO_COLOUR}";
    fi
}
function echo_lightyellow {
    if [[ "${QUIET}" == 0 ]]; then
        echo -e "${LIGHT_YELLOW}${@}${NO_COLOUR}";
    fi
}
function echo_lightmagento {
    if [[ "${QUIET}" == 0 ]]; then
        echo -e "${LIGHT_MAGENTO}${@}${NO_COLOUR}";
    fi
}
function echo_std {
    if [[ "${QUIET}" == 0 ]]; then
        echo -e "${@}";
    fi
}
function echo_verbose {
    if [[ "${VERBOSE}" == 1 ]]; then
        echo -e "${@}";
    fi
}
function echo_cyan_title {
    local toprint="${@}"
    local line=$(printf %${#toprint}s |tr " " "-"; echo)
    echo_cyan "\n${@}\n${line}"
}

# JSON
function json_get_key {
    assert_dependencies jq
    echo $(echo "${2}" | jq -r .$1)
}

# DOCKER
function docker_build {
    assert_dependencies docker
    assert_json_key "image" "${2}"
    local image_tag=$(json_get_key "image" "${2}")

    echo_cyan "building image ${image_tag}"
    docker build --tag ${image_tag} ${1}
}
function docker_push {
    assert_dependencies docker
    assert_json_key "image" "${1}"
    local image_tag=$(json_get_key "image" "${1}")

    echo_cyan "pushing image ${image_tag}"
    docker push ${image_tag}
}
function docker_get_tag {
    echo "${1}:${2}-${3}"
}

# KUBERNETES
function execute_kubectl_command {
    set +u
    if [[ -z ${KUBECONFIG_FILE} ]];then
        # cache kubeconfig for whole runtime
        assert_dependencies kubectl
        assert_aws_access_key_id
        assert_aws_secret_access_key
        assert_aws_default_region
        export KUBECONFIG_FILE=$(tempfile)
        execute_aws_command eks     \
            update-kubeconfig       \
                --name ${ENVIRONMENT_ID}-eks \
                --dry-run > "${KUBECONFIG_FILE}"
    fi
    set -u

    echo_verbose "--> kubectl ${@}"
    kubectl --kubeconfig "${KUBECONFIG_FILE}" "${@}"
}
function kubectl_delete_namespace {
    execute_kubectl_command delete namespace "${1}"
}
function kubernetes_runtime_ls {
    echo_cyan_title "${2}"
    execute_kubectl_command get "${2}" -o wide --namespace "${1}"
    echo
}
function kubernetes_runtime_describe {
    echo_cyan_title "${2}"
    execute_kubectl_command describe "${2}" --namespace "${1}"
}
function kubernetes_create_namespace {
    execute_kubectl_command create namespace "${1}"
}
function kubernetes_create_resource {
    if [[ "${#}" != 2 ]]; then
        echo_red "kubernetes_create_resource requires 2 parameters namespace and template"
        exit 1
    fi
    local namespace="${1}"
    local template="${2}"

    echo "${template}" \
    | execute_kubectl_command apply --namespace "${namespace}" -f -
}
function kubernetes_get_pod_names {
    echo $(execute_kubectl_command --namespace "${1}" get pods -o name)
}
function kubernetes_deployment_log {
    assert_dependencies kubectl
    assert_aws_access_key_id
    assert_aws_secret_access_key
    assert_aws_default_region
    local pods="$(kubernetes_get_pod_names "${1}")"
    echo_cyan "found pods: ${pods}"

    for pod in ${pods} ; do
        echo_cyan "pod :${pod}"
        kubernetes_get_pod_logs "${1}" "${pod}"
    done
}
function kubernetes_get_pod_logs {
    execute_kubectl_command --namespace "${1}" logs ${2} ${3}
}

# MISCELLANEOUS
function calculate_date {
    echo $(($(date -d "${1} UTC" +%s%N)/1000000))
}
function assert_dependencies {
  for program in "${@}"; do
    if [[ "$(which ${program})" == "" ]];then
        echo_red "You need to install ${program} and make it accessible (update PATH) to be able to run the script, you can also use the option ${ARG_HOST_MODE} mode after installing the dependencies"
        exit 1
    fi
  done
}

# AWS
function execute_aws_command {
    if [[ "${@}" == "" ]]; then
        echo_red "please provide ${0} aws_command parameter"
        exit 1
    fi

    assert_dependencies aws
    assert_aws_access_key_id
    assert_aws_secret_access_key
    assert_aws_default_region
    aws ${@} --region ${AWS_DEFAULT_REGION}
}

# ASSERT PARAMETERS
ARG_KIND="-k|--kind"
ARG_ID="-i|--id"
ARG_ENVIRONMENT="-e|--environment"
ARG_DEPLOYMENT="-d|--deployment"
ARG_COMMAND="-c|--command"
ARG_BYPASS_PROMPT="-b|--bypass_prompt"
ARG_HOST_MODE="-h|--host"
ARG_TERRAFORM_INFO="--terraform_info"
ARG_QUIET_SHORT="-q"
ARG_QUIET_LONG="--quiet"
ARG_SERVICE_ID="-s|--service"
ARG_AWS_ACCESS_KEY_ID="--aws_access_key_id"
ARG_AWS_SECRET_ACCESS_KEY="--aws_secret_access_key"
ARG_AWS_DEFAULT_REGION="--aws_default_region"
ARG_PROJECT_ID="-p|--project_id"
ARG_PARAMETERS="-x | --xparams"
ARG_DOCKER_QUIET_SHORT="-dq"
ARG_DOCKER_QUIET_LONG="--docker_quiet"
ARG_FORCE_DOCKER_LONG="--force_docker"
ARG_VERBOSE_SHORT="-v"
ARG_VERBOSE_LONG="--verbose"
ARG_NO_TTY_LONG="--no_tty"
function assert_kind {
    set +u
    if [[ "${DEPLOYMENT_KIND}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_KIND} or environment variable DEPLOYMENT_KIND"
        exit 1
    fi
    set -u
}
function assert_deployment_id {
    set +u
    if [[ "${DEPLOYMENT_ID}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_DEPLOYMENT} or environment variable DEPLOYMENT_ID"
        exit 1
    fi
    set -u
}
function assert_environment_id {
    set +u
    if [[ "${ENVIRONMENT_ID}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_ENVIRONMENT} or environment variable ENVIRONMENT_ID"
        exit 1
    fi
    set -u
}
function assert_service_id {
    set +u
    if [[ "${SERVICE_ID}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_SERVICE_ID} or environment variable SERVICE_ID"
        exit 1
    fi
    set -u
}
function assert_aws_access_key_id {
    set +u
    if [[ "${AWS_ACCESS_KEY_ID}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_AWS_ACCESS_KEY_ID} or environment variable AWS_ACCESS_KEY_ID"
        exit 1
    fi
    set -u
}
function assert_aws_secret_access_key {
    set +u
    if [[ "${AWS_SECRET_ACCESS_KEY}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_AWS_SECRET_ACCESS_KEY} or environment variable AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    set -u
}
function assert_aws_default_region {
    set +u
    if [[ "${AWS_DEFAULT_REGION}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_AWS_DEFAULT_REGION} or environment variable AWS_DEFAULT_REGION"
        exit 1
    fi
    set -u
}
function assert_project_id {
    set +u
    if [[ "${PROJECT_ID}" == "" ]];then
        echo_red "Command ${DEPLOYER_COMMAND} requires parameter ${ARG_PROJECT_ID} or environment variable PROJECT_ID"
        exit 1
    fi
    set -u
}
function assert_terraform_file {
    set +u
    if [[ ! -f ${terraform_var_file} ]];then
        echo_red "The deployment ${DEPLOYMENT_KIND}/${ENVIRONMENT_ID}.${DEPLOYMENT_ID} have no matching file at ${terraform_var_file}"
        exit 1
    fi
    set -u
}
function assert_json_key {
    set +u
    if [[ "${2}" == "" || "$(echo "${2}" | jq ". |has(\"${1}\")")" == "false" ]]; then
        echo_red "missing parameter -x '{\"${1}\":\"<...>\", ...}'"
        exit 1
    fi
    set -u
}

# TERRAFORM
TERRAFORM_TFSTATE_S3_KEY="terraform_states"
VAR_FILE_EXTENSION="tfvars"
function execute_terraform {
    # any parameter will be passed as it is to terraform execution
    assert_dependencies terraform
    assert_kind
    assert_deployment_id
    assert_environment_id
    assert_project_id
    assert_aws_default_region

    local terraform_command="apply"
    if [[ "${DEPLOYER_COMMAND}" == "${COMMAND_DOWN}" ]]; then
        terraform_command="destroy"
    fi
    deployment_kind_path="$(get_deployment_kind_path)"

    (
        export AWS_SDK_LOAD_CONFIG=true # aws sdk environment variable
        if [[ "${TERRAFORM_INFO}" == 1 ]];then
            export TF_LOG=INFO # terraform environment variable
        fi

        cd "${deployment_kind_path}/terraform"
        rm -rf .terraform/terraform.tfstate

        # init
        local terraform_force_copy=""
        if [[ "${BYPASS_PROMPT}" == 1 ]];then
            terraform_force_copy="-force-copy"
        fi
        local init_command="terraform init "
        init_command+="-backend-config bucket=$(get_project_bucket_name) "
        init_command+="-backend-config key=$(get_terraform_remote_state_path) "
        init_command+="-backend-config region=${AWS_DEFAULT_REGION} "
        init_command+="${terraform_force_copy}"
        echo_verbose "\n${init_command}"
        ${init_command}

        # execute
        local terraform_auto_approve=""
        if [[ "${BYPASS_PROMPT}" == 1 ]];then
            terraform_auto_approve="-auto-approve"
        fi
        execute_command="terraform ${terraform_command} "
        execute_command+="${terraform_auto_approve} "
        execute_command+=" ${@} "

        echo_verbose "\n${execute_command}"
        ${execute_command}
    )
}
function get_terraform_file_path {
    echo "${RESOURCE_PATH}/${1}/terraform/deployment_${2}.${VAR_FILE_EXTENSION}"
}
function get_project_bucket_name {
  echo "${PROJECT_ID}"
}
function get_terraform_remote_state_path {
  echo "${TERRAFORM_TFSTATE_S3_KEY}/${ENVIRONMENT_ID}.${DEPLOYMENT_KIND}.${DEPLOYMENT_ID}"
}

# COMMANDS
COMMAND_UP="up"
COMMAND_DOWN="down"
COMMAND_LS="ls"
COMMAND_DESCRIBE="describe"
COMMAND_LOG="log"
COMMAND_BUILD="build"
COMMAND_PUSH="push"
