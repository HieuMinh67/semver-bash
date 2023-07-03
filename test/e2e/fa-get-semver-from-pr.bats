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

@test "test creating PR" {
    echo '# Test PR does not contain semver string' >&3
    run semver get $pr_number
    assert_failure
    assert_output --partial "This Pull Request does not contain any semantic version string in title or body."

    echo '# Test PR title contain +semver:major' >&3
    _update_pr "${pr_number}" "E2E Test PR for +semver:major - ${rand}"
    run semver get $pr_number
    assert_success
    assert_output --partial "Semver type: ${selected_type}"

    echo '# Test PR body contain +semver:major' >&3
    _update_pr "${pr_number}" "E2E Test PR - ${rand}" "Test body for +semver:major"
    run semver get $pr_number
    assert_success
    assert_output --partial "Semver type: ${selected_type}"
}
