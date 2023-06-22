echo "# this file is located in 'cmd/get_command.sh'"
echo "# code for 'semver get' goes here"
echo "# you can edit it freely and regenerate (it will not be overwritten)"
inspect_args

get_pr_git_port "${args[source_value]}"

get_latest_tag() {
  current_branch=$1
  if [[ "$current_branch" == "master" || "$current_branch" == "main" ]]; then
    tag=$(get_latest_release_git_port | jq ".tag_name")
  elif [[ "$current_branch" =~ ^release\/v[0-9]+\.[0-9]+$ ]]; then
    release_version=$(echo "$current_branch" | cut -d '/' -f 2)
    echo "$release_version"
    tag=$(get_ref_git_port "tags/$release_version" | jq '.[0].ref' | sed 's/refs\/tags\///')
  fi

  if [ -z "$tag" ]; then
#    exit 1
    tag=v0.1.0-alpha+0
  fi
}

pr_title=$(echo "$pr_details" | jq -r ".title")
pr_body=$(echo "$pr_details" | jq -r ".body")
branch_name=$(echo "$pr_details" | jq -r ".base.ref")

semver_pattern="\+semver:(major|minor|patch|pre|build)"
if [[ "$pr_title" =~ $semver_pattern ]] || [[ "$pr_body" =~ $semver_pattern ]]; then
    SEMVER_TYPE=${BASH_REMATCH[1]}
else
    echo "This PR does not contain a semantic version string."
    exit 1
fi

get_latest_tag "$branch_name"

# GET BUILD NUMBER
sha=$(echo "$pr_details" | jq -r ".head.sha")
get_workflow_run_git_port "$sha"
build_number=$(echo "${workflow_run_details}" | jq -r ".workflow_runs[0].run_number")

components=$(echo "$tag" | sed 's/v//; s/-.*//; s/"//')
major=$(echo "$components" | cut -d '.' -f 1)
minor=$(echo "$components" | cut -d '.' -f 2)
patch=$(echo "$components" | cut -d '.' -f 3)
echo "Tag: $tag"
pre=$(echo "$tag"  | sed 's/.*-\(.*\)+.*/\1/')
echo "Major: $major"
echo "Minor: $minor"
echo "Patch: $patch"
echo "Pre: $pre"

case $SEMVER_TYPE in
  "major")
    semver="v$((major+1)).0.0-alpha+$build_number"
    ;;

  "minor")
    semver="v$major.$((minor+1)).0-alpha+$build_number"
    ;;

  "patch")
    semver="v$major.$minor.$((patch+1))-alpha+$build_number"
    ;;

  "build")
    semver="v$major.$minor.$patch-alpha+$build_number"
    ;;
  "pre")
    case $pre in
      alpha)
        semver="v$major.$minor.$patch-beta+$build_number"
        ;;
      *)
        semver="v$major.$minor.$patch-rc+$build_number"
        ;;
    esac
esac
echo "Final: $semver"