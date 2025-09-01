#!/usr/bin/env bats

load 'test_helper'

# MIBS test
@test "can download mibs" {
    run run_in_container download-mibs
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Downloading documents and extracting MIB files"]]
}
