#!/usr/bin/env bash

_common_setup() {
    load '../test_helper/bats-support/load'
    load '../test_helper/bats-assert/load'
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    export PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/../.." >/dev/null 2>&1 && pwd )"
    # make executables in build/ visible to PATH
    PATH="$PROJECT_ROOT/build:$PATH"

    test_envrc="${PROJECT_ROOT}/test/.envrc"
    source "${test_envrc}"

    test_secrets="${PROJECT_ROOT}/test/.secrets"
    if [[ -f "${test_secrets}" ]]; then
        source "${test_secrets}"
    elif [[ -z "${GITHUB_PAT_OWNER}" ]] || [[ -z "${GITHUB_PAT_CONTRIBUTOR}" ]]; then
        echo "Please setup Git Tokens in test/.secrets file"
        exit 1
    fi

    export contributor_git_sandbox_repo="${PROJECT_ROOT}"/test/sandbox/github/contributor
    cd "${contributor_git_sandbox_repo}"
    export default_branch=$(git rev-parse --abbrev-ref HEAD)
    cd "${PROJECT_ROOT}"
}

_create_git_branch() {
    rand=$1
    name=$2

    cd "${contributor_git_sandbox_repo}"
    
    branch_name=fork/e2e/fa/"${name}-${rand}"

    git checkout -b "${branch_name}" > /dev/null 2>&1
    echo $rand > test.txt
    git add test.txt
    git commit -m "E2E test commit - 123" > /dev/null 2>&1
    git push -f --set-upstream origin "${branch_name}" > /dev/null 2>&1

    sleep 5

    echo $branch_name
}

_create_pr() {
    branch_name=$1
    title=$2

    github_adaptor="${PROJECT_ROOT}"/pkg/adaptors/github
    github_openapi_client="${github_adaptor}"/openapi/client.sh

    source "${github_openapi_client}"
    source "${github_adaptor}"/execute_github_api.sh

    cd "${contributor_git_sandbox_repo}"

    # execute_github_api orgsGet org=BeanCloudServices
    GITHUB_TOKEN=${GITHUB_PAT_CONTRIBUTOR}
    pr_number=$(execute_github_api pullsCreate owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}" head:="\"${GITHUB_REPOSITORY_CONTRIBUTOR}:${branch_name}\"" base:='"main"' title:="\"${title}\"" | jq -r '.number')

    echo "${pr_number}"
}

_close_pr() {
    pr_number=$1

    github_adaptor="${PROJECT_ROOT}"/pkg/adaptors/github
    github_openapi_client="${github_adaptor}"/openapi/client.sh

    source "${github_openapi_client}"
    source "${github_adaptor}"/execute_github_api.sh

    cd "${contributor_git_sandbox_repo}"

    # execute_github_api orgsGet org=BeanCloudServices
    GITHUB_TOKEN=${GITHUB_PAT_CONTRIBUTOR}

    execute_github_api pullsUpdate owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}" pull_number=${pr_number} state:='"closed"' --dry-run

}

_delete_git_branch() {
    branch_name=$1

    echo "dir to cd to is ${contributor_git_sandbox_repo}"
    echo "branch to delete ${branch_name} and branch to restore is ${default_branch}"

    cd "${contributor_git_sandbox_repo}"

    echo "Deleting test branch"
    sleep 5
    git checkout "${default_branch}"
    git push origin -d "${branch_name}"
    git branch -D "${branch_name}"
}

_create_tag() {
    tag_name=$1
    message=$2

    cd "${PROJECT_ROOT}"/test/sandbox/github/upstream

    git tag -a "${tag_name}" -m "${message}"
    git push --tags
    git push origin "${tag_name}"
}

_delete_tag() {
    tag_name=$1

    cd "${PROJECT_ROOT}"/test/sandbox/github/upstream

    git tag -d "${tag_name}"
    git push origin --delete "${tag_name}"
}
