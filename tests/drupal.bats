#!/usr/bin/env bats

# Run server.bats before.

setup() {
    cd demo-drupal
    if [ "${ANDOCK_CONNECTION}" = "" ]; then
        export ANDOCK_CONNECTION="default"
    fi

    if [ "${ANDOCK_ROOT_USER}" = "" ]; then
        export ANDOCK_ROOT_USER="root"
    fi
    if [ "${ANDOCK_TEST_SUFFIX}" = "" ]; then
        export ANDOCK_TEST_SUFFIX=$(date +%s);
    fi
}


@test "build drupal ${ANDOCK_TEST_SUFFIX}" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin build -e "branch=master, random_test_suffix=${ANDOCK_TEST_SUFFIX}"
    [ $status = 0 ]
}
@test "deploy drupal ${ANDOCK_TEST_SUFFIX}" {
    run ../../bin/andock.sh @${ANDOCK_CONNECTION} fin deploy -e "branch=master, random_test_suffix=${ANDOCK_TEST_SUFFIX}"
    [ $status = 0 ]
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master${ANDOCK_TEST_SUFFIX}.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "drush sql-sync @self @demo-drupal.master" {
    cd web
    fin drush sql-sync --local @self @demo-drupal.master -y
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master${ANDOCK_TEST_SUFFIX}.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "drush sql-sync @demo-drupal.master @elf" {
    cd web
    fin drush sql-sync --local @demo-drupal.master @self -y
}

@test "deploy: Testing page status" {
    run 'curl -sL -I https://master${ANDOCK_TEST_SUFFIX}.demo-drupal.dev.andock.ci | grep "HTTP/1.1 200 OK"'
    [[ "$output" =~ "HTTP/1.1 200 OK" ]]
}

@test "Setup dev environment" {
    cd web
    git checkout develop
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} fin build -e "branch=develop, random_test_suffix=${ANDOCK_TEST_SUFFIX}"
    [ $status = 0 ]
    run ../../../bin/andock.sh @${ANDOCK_CONNECTION} fin deploy -e "branch=develop, random_test_suffix=${ANDOCK_TEST_SUFFIX}"
    [ $status = 0 ]
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