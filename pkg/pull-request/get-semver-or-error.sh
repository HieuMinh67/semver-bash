#!/usr/bin/env bash

#######################################
# Check if the PR has semver or not
# Globals:
#   None
# Arguments:
#   pr
#######################################

function pr.get_semver_or_error() {
    declare -A pr_details
    pr_details["title"]=$1
    pr_details["body"]=$2

    result=$(pr.has_semver pr_details)
    semver_pattern="\+semver:(major|minor|patch|pre|build)"
    if [[ $result == "true" ]]; then
        [[ ${pr_details["title"]} =~ $semver_pattern || ${pr_details["body"]} =~ $semver_pattern ]]
        semver_type=${BASH_REMATCH[1]}
        echo "Semver type: $semver_type"
    else
        echo "This Pull Request does not contain any semantic version string in title or body."
        exit 1
    fi
}
