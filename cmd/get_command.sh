echo "# this file is located in 'cmd/get_command.sh'"
echo "# code for 'semver get' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

pr_details=$(get_pr_git_port "${args[source_value]}")

pr_title=$(echo "$pr_details" | jq -r ".title")
pr_body=$(echo "$pr_details" | jq -r ".body")

semver_pattern="\+semver:(major|minor|patch|pre|build)"
if [[ "$pr_title" =~ $semver_pattern ]] || [[ "$pr_body" =~ $semver_pattern ]]; then
    semver_type=${BASH_REMATCH[1]}
    echo "Semver type: $semver_type"
else
    echo "This Pull Request does not contain any semantic version string in title or body."
    exit 1
fi