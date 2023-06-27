setup() {
    load '../test_helper/common-setup'
    _common_setup
    
    export rand=${RANDOM}
    export tag_name="v1.1.0-alpha+5"

    export semver_major_branch=$(_create_git_branch "${rand}" "semver_major")

    echo "Tag: $tag_name" >&3
    _create_tag $tag_name $rand

    export release_id=$(_create_release $tag_name)
    echo "Release id: $release_id"

    export pr_number=$(_create_pr "${semver_major_branch}" "E2E Test PR +semver:pre - ${rand}")
}

teardown() {
    echo ""
    _delete_tag "$tag_name"
    _delete_release "$release_id"
    _close_pr "${pr_number}"
    _delete_git_branch "${semver_major_branch}"
}

@test "test +semver:pre" {
    echo ""

    run semver get "$pr_number"
    assert_output --partial "v1.1.0-beta+"
}
