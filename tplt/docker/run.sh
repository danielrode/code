#!/usr/bin/env bash

podman run --rm -it -v "$PWD:$PWD" -w "$PWD" lumen
