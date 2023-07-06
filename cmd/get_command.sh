echo "# this file is located in 'cmd/get_command.sh'"
echo "# code for 'semver get' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

pr_details=$(get_pr_git_port "${args[source_value]}")

pr_title=$(echo "$pr_details" | jq -r ".title")
pr_body=$(echo "$pr_details" | jq -r ".body")

pr.get_semver_or_error "$pr_title" "$pr_body"