#!/usr/bin/env bash

#######################################
# Get GitHub release detail
# Globals:
#   GITHUB_REPOSITORY_NAME
#   GITHUB_REPOSITORY_OWNER
# Arguments:
# Return:
#   release_detail json
#######################################
get_latest_release_github_adaptor() {
    local release_detail
    release_detail=$(execute_github_api reposGetLatestRelease owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}")
    echo "$release_detail"
}

#######################################
# Get GitHub release detail
# Globals:
#   GITHUB_REPOSITORY_NAME
#   GITHUB_REPOSITORY_OWNER
# Arguments:
#   tag
# Return:
#   release_detail json
#######################################
get_release_by_tag_github_adaptor() {
    local tag=$1
    local release_detail

    if [[ -z $tag ]]; then
        echo "Error: Tag parameter is missing"
        return 1
    fi

    release_detail=$(execute_github_api reposGetReleaseByTag owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}" tag="${tag}")
    echo "$release_detail"
}