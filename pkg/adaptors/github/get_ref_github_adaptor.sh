#!/usr/bin/env bash

#######################################
# Get GitHub Reference details
# Globals:
#   GITHUB_REPOSITORY_NAME
#   GITHUB_REPOSITORY_OWNER
#   ref
# Arguments:
#   ref
# Return:
#   refs json
#######################################
function get_ref_github_adaptor() {
  local ref=$1
  refs=$(execute_github_api gitListMatchingRefs owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}" ref="${ref}")
  echo "${refs}"
}
