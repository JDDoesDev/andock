#!/usr/bin/env bats

# Run server.bats before.

load setup_helper


@test "deploy" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} deploy -e "branch=master"
    [[ $status == 0 ]]
}

@test "deploy: Testing page status" {
    run curl -sL -I "http://master.demo-project.dev.andock.ci"
    echo $output | grep "HTTP/1.1 200 OK"
    unset output

}

@test "deploy: Testing page content" {
    run curl -sL http://master.demo-project.dev.andock.ci
    echo $output | grep "Hello Andock"
    unset output
}

@test "url: Show url" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment url -e "branch=master"
    [[ $status == 0 ]]
}

@test "fin: Execute fin version" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin "version" -e "branch=master"
    [[ $status == 0 ]]
}

@test "up" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment up -e "branch=master"
    [[ $status == 0 ]]
}

@test "test" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment test -e "branch=master"
    [[ $status == 0 ]]
}

@test "rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment rm -e "branch=master"
  [[ $status == 1 ]]
}

@test "rm --force" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment rm --force -e "branch=master"
  [[ $status == 1 ]]
}

@test "rm: Testing page status" {
    run curl -sL -I "http://master.demo-project.dev.andock.ci"
    echo "$output" | grep "HTTP/1.1 404 Not Found"
    unset output
}

@test "build deploy" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} build deploy -e "branch=master"
    [[ $status == 0 ]]
    run curl -sL http://master.demo-project.dev.andock.ci
    echo $output | grep "Hello Andock"
    unset output
}


@test "rm" {
  run ../../bin/andock.sh @${ANDOCK_CONNECTION} environment rm --force -e "branch=master"
  fin rm -f
  [[ $status == 0 ]]
}

teardown() {
    echo "Status: $status"
    echo "Output:"
    echo "================================================================"
    for line in "${lines[@]}"; do
        echo $line
    done
    echo "================================================================"
}