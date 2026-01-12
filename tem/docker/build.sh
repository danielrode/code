#!/usr/bin/env bash
# author: Daniel Rode


# Build container
cd "$(dirname "$0")"
podman build --tag IMG_NAME .

# Publish build
# - Go to https://github.com/settings/tokens/new
# - Check `write:packages` and generate
podman login ghcr.io --username GH_USERNAME
# *paste token*
podman image push IMG_NAME ghcr.io/danielrode/IMG_NAME:v1.9.0
