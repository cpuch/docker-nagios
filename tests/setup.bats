#!/usr/bin/env bats

load 'test_helper'

# Basic container test
@test "test container is up and running" {
    run run_in_container echo "Container is working"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Container is working" ]]
}
