#!/usr/bin/env bash


# Build container
cd "$(dirname "$0")"
podman build -t lumen .

# Publish build
# - Go to https://github.com/settings/tokens/new
# - Check `write:packages` and generate
podman login ghcr.io --username GH_USERNAME
# *paste token*
podman image push lumen ghcr.io/danielrode/lumen:v1.9.0
