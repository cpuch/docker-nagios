#!/usr/bin/env bats

load 'test_helper'

# Supervisord tests
@test "supervisord is running all services" {
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status
    [ "$status" -eq 0 ]
    [[ "$output" =~ "nagios".*"RUNNING" ]]
    [[ "$output" =~ "apache2".*"RUNNING" ]]
}

@test "can stop and start nagios service" {
    # Stop nagios
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf stop nagios
    [ "$status" -eq 0 ]
    
    # Start nagios
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf start nagios
    [ "$status" -eq 0 ]
    
    # Verify it's running
    sleep 2
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status nagios
    [ "$status" -eq 0 ]
    [[ "$output" =~ "RUNNING" ]]
}

@test "can stop and start apache2 service" {
    # Stop apache2
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf stop apache2
    [ "$status" -eq 0 ]
    
    # Start apache2
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf start apache2
    [ "$status" -eq 0 ]
    
    # Verify it's running
    sleep 2
    run run_in_container supervisorctl -c /etc/supervisor/conf.d/supervisord.conf status apache2
    [ "$status" -eq 0 ]
    [[ "$output" =~ "RUNNING" ]]
}

@test "nagios process is running" {
    run run_in_container pgrep nagios
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "apache2 process is running" {
    run run_in_container pgrep apache2
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}
