#!/usr/bin/env bats

load 'test_helper'

# Configuration tests
@test "nagios config files exist" {
    run run_in_container test -f etc/nagios.cfg
    [ "$status" -eq 0 ]
    
    run run_in_container test -f etc/cgi.cfg
    [ "$status" -eq 0 ]
    
    run run_in_container test -f etc/resource.cfg
    [ "$status" -eq 0 ]
}

@test "nagios object config files exist" {
    run run_in_container test -f etc/objects/commands.cfg
    [ "$status" -eq 0 ]
    
    run run_in_container test -f etc/objects/contacts.cfg
    [ "$status" -eq 0 ]
    
    run run_in_container test -f etc/objects/localhost.cfg
    [ "$status" -eq 0 ]
    
    run run_in_container test -f etc/objects/templates.cfg
    [ "$status" -eq 0 ]
}

@test "nrpe config file exists" {
    run run_in_container test -f etc/nrpe.cfg
    [ "$status" -eq 0 ]
}

@test "nsca config file exists" {
    run run_in_container test -f etc/nsca.cfg
    [ "$status" -eq 0 ]
}

@test "send_nsca config file exists" {
    run run_in_container test -f etc/send_nsca.cfg
    [ "$status" -eq 0 ]
}

@test "apache config files exist" {
    run run_in_container apache2ctl -t -D DUMP_INCLUDES
    [ "$status" -eq 0 ]
    [[ "$output" =~ "apache2.conf" ]] && [[ "$output" =~ "000-default.conf" ]] && [[ "$output" =~ "nagios.conf" ]]
}

@test "supervisord config file exists" {
    run run_in_container test -f /etc/supervisor/conf.d/supervisord.conf
    [ "$status" -eq 0 ]
}

@test "nagios configuration is valid" {
    run run_in_container bin/nagios -v etc/nagios.cfg
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Total Warnings: 0" ]] || [[ "$output" =~ "Things look okay" ]]
}

@test "apache configuration is valid" {
    run run_in_container apache2ctl configtest
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Syntax OK" ]]
}