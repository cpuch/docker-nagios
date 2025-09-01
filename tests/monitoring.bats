#!/usr/bin/env bats

load 'test_helper'

@test "nagios var directory has correct permissions" {
    run run_in_container ls -la /opt/nagios/var/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "nagios" ]]
}

@test "nagios plugins directory exists" {
    run run_in_container test -d /opt/nagios/libexec
    [ "$status" -eq 0 ]
}

@test "basic nagios plugins are available" {
    run run_in_container test -x /opt/nagios/libexec/check_ping
    [ "$status" -eq 0 ]
    
    run run_in_container test -x /opt/nagios/libexec/check_http
    [ "$status" -eq 0 ]
}

@test "nagios can execute a basic plugin check" {
    run run_in_container /opt/nagios/libexec/check_ping -H 127.0.0.1 -w 100,20% -c 500,60%
    [ "$status" -eq 0 ]
    [[ "$output" =~ "PING OK" ]]
}