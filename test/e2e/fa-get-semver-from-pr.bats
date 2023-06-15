setup() {
    load '../test_helper/common-setup'
    _common_setup
    
    export rand=${RANDOM}
    export semver_major_branch=$(_create_git_branch "${rand}" "semver_major")

    export tag_name="v1.1.0-alpha+10-rc"
    _create_tag $tag_name "Test tag - ${rand}"

    export pr_number=$(_create_pr "${semver_major_branch}" "E2E Test PR +semver:major - ${rand}")
}

teardown() {
    echo ""
    _close_pr "${pr_number}"
    _delete_git_branch "${semver_major_branch}"
    _delete_tag $tag_name
}

#@test "test creating PR" {
#    echo ""
#
#    # run semver get
#}

@test "test +semver:major" {
    echo ""

    run semver get "$pr_number"
    assert_output --partial "v2.1.0-alpha+$build_number"
}
