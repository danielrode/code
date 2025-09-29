#!/usr/bin/env bash
# Author: Daniel Rode
# Name:
# Tags:
# Dependencies:
#   Bash 4.3+
#   pv
#   ...
# Version: 1
# Created:
# Updated: -


# Description:
# ...
# ...


# Setup temp directory and set it to be removed on exit
umask 077
tmpdir="$(mktemp -d)"
function cleanup { rm -fr -- "$tmpdir"; }
trap cleanup EXIT


# Run jobs in parallel, with limited number of concurrent tasks
# NOTE the better way to do this is with GNU Parallel, if it is available
max_workers=16
for path in path-of-interest/*
do (
  cd "$path"
  long-running-command
  )&
  echo "Started task $path"

  # Limit number of jobs running in parallel
  (( "$(jobs -p | wc -l)" == $max_workers)) && wait -n
done | pv --timer --bytes --numeric --line-mode
wait


# Use array to store options
cmd_args=(
  --flag1 value1
  # I included this flag because reasons
  --flag2 value2
)
command "${cmd_args[@]}"
