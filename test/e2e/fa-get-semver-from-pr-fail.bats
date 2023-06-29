setup() {
    load '../test_helper/common-setup'
    _common_setup
    
    export rand=${RANDOM}
    export semver_major_branch=$(_create_git_branch "${rand}" "semver_major")

    export pr_number=$(_create_pr "${semver_major_branch}" "E2E Test PR - ${rand}")
}

teardown() {
    echo ""
    _close_pr "${pr_number}"
    _delete_git_branch "${semver_major_branch}"
}

@test "test PR not contain semver str" {
    echo ""

    run semver get $pr_number
    assert_failure
    assert_output --partial "This Pull Request does not contain any semantic version string in title or body."
}
