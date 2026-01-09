#!/usr/bin/env bash
# author: Daniel Rode


podman run \
    --rm \
    --interactive --tty \
    --volume "$PWD:$PWD" \
    --workdir "$PWD" \
    CON_IMG \
;
