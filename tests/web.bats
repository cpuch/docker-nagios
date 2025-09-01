#!/usr/bin/env bats

load 'test_helper'

# Web interface tests
@test "nagios web interface is accessible without auth" {
    run run_in_container curl -sI http://localhost/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "401 Unauthorized" ]] || [[ "$output" =~ "HTTP/1.1 401" ]]
}

@test "nagios web interface rejects bad credentials" {
    run run_in_container curl -sI -u "nagiosadmin:badpassword" http://localhost/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "401 Unauthorized" ]] || [[ "$output" =~ "HTTP/1.1 401" ]]
}

@test "nagios web interface accepts good credentials" {
    run run_in_container curl -sI -u "nagiosadmin:${NAGIOSADMIN_PASSWORD}" http://localhost/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "HTTP/1.1 200" ]] || [[ "$output" =~ "200 OK" ]]
}

@test "nagios status.cgi is accessible" {
    run run_in_container curl -sI -u "nagiosadmin:${NAGIOSADMIN_PASSWORD}" http://localhost/nagios/cgi-bin/status.cgi
    [ "$status" -eq 0 ]
    [[ "$output" =~ "HTTP/1.1 200" ]] || [[ "$output" =~ "200 OK" ]]
}

@test "nagios config.cgi is accessible" {
    run run_in_container curl -sI -u "nagiosadmin:${NAGIOSADMIN_PASSWORD}" http://localhost/nagios/cgi-bin/config.cgi
    [ "$status" -eq 0 ]
    [[ "$output" =~ "HTTP/1.1 200" ]] || [[ "$output" =~ "200 OK" ]]
}

@test "can get nagios main page content" {
    run run_in_container curl -s -u "nagiosadmin:${NAGIOSADMIN_PASSWORD}" http://localhost/
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Nagios" ]]
}

@test "apache is listening on port 80" {
    run run_in_container netstat -tlnp
    [ "$status" -eq 0 ]
    [[ "$output" =~ ":80" ]]
}

@test "htpasswd file exists and is readable" {
    run run_in_container test -r etc/htpasswd.users
    [ "$status" -eq 0 ]
}

@test "apache virtual host configuration" {
    run run_in_container test -f /etc/apache2/sites-enabled/000-default.conf
    [ "$status" -eq 0 ]
}
