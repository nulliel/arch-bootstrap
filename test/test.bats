load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

@test "Should add numbers together" {
    assert_equal $(echo 1+1 | bc) 2
}