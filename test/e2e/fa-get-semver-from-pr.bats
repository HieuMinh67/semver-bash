setup() {
    load '../test_helper/common-setup'
    _common_setup
    
    export rand=${RANDOM}
    export semver_major_branch=$(_create_git_branch "${rand}" "semver_major")

    
    semver_types=("major" "minor" "patch" "pre" "build")
    export selected_type=${semver_types[$rand % ${#semver_types[@]}]}

    export pr_number=$(_create_pr "${semver_major_branch}" "E2E Test PR for +semver:${selected_type} - ${rand}")
}

teardown() {
    echo ""
    _close_pr "${pr_number}"
    _delete_git_branch "${semver_major_branch}"
}

@test "test creating PR" {
    echo ""

    run semver get $pr_number
    assert_success
    assert_output --partial "Semver type: ${selected_type}"
}
