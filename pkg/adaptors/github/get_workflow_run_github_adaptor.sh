#!/usr/bin/env bash

#######################################
# Get GitHub Check Runs details
# Globals:
#   GITHUB_REPOSITORY_NAME
#   GITHUB_REPOSITORY_OWNER
# Arguments:
#   sha
# Return:
#   workflow_run_details json
#######################################
function get_workflow_run_github_adaptor() {
  sha=$1
  workflow_run_details=$(execute_github_api actionsListWorkflowRunsForRepo owner="${GITHUB_REPOSITORY_OWNER}" repo="${GITHUB_REPOSITORY_NAME}" head_sha="${sha}")
#  echo "${workflow_run_details}"
}