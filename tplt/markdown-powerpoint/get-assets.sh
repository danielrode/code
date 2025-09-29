#!/usr/bin/env bash


set -e  # Exit on error
set -x  # Print code lines as they are executed
cd "$(dirname "$0")"  # Switch directory to where this script is


function main {
    # Print current date and time
    echo -n "It is now: "
    date

    # Make sure assets directory exists
    mkdir -p assets

    # Copy local assets
    cp -v /path/to/asset1 ./assets/
    cp -v /path/to/asset2 ./assets/

    # Download assets
    wget something something  # todo
}
main &> "./$(basename "$0").log"
