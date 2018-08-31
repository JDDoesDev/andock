#!/usr/bin/env sh
set -e

test_method=$1
image=$2

if [ "${test_method}" = "" ]; then
    test_method="lxd"
fi

cd ${test_method}


echo "Cleanup $test_method components..."
./cleanup.sh



