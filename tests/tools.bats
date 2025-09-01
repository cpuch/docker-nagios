#!/usr/bin/env bats

load 'test_helper'

# External tools tests

@test "ping utility is available" {
    run run_in_container ping -V
    [ "$status" -eq 0 ]
    [[ "$output" =~ "ping" ]]
}

@test "curl is available" {
    run run_in_container curl --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "curl" ]]
}

@test "network connectivity works" {
    run run_in_container ping -c 3 8.8.8.8
    [ "$status" -eq 0 ]
    [[ "$output" =~ "3 packets transmitted, 3 received" ]]
}

@test "dns resolution works" {
    run run_in_container nslookup google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ "google.com" ]]
}

@test "essential system tools are available" {
    # Test basic system commands
    run run_in_container which ps
    [ "$status" -eq 0 ]
    
    run run_in_container which netstat
    [ "$status" -eq 0 ]
    
    run run_in_container which grep
    [ "$status" -eq 0 ]
}
