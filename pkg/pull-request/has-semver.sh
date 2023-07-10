#!/usr/bin/env bash

#######################################
# Check if the PR has semver or not
# Globals:
#   None
# Arguments:
#   pr
#######################################

function pr.has_semver() {
    local -n pr=$1

    semver_pattern="\+semver:(major|minor|patch|pre|build)"
    if [[ ${pr["title"]} =~ $semver_pattern ]] || [[ ${pr["body"]} =~ $semver_pattern ]]; then
        pr["semver_type"]=${BASH_REMATCH[1]}
        echo "true"
    else
        echo ""
    fi
}