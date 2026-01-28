#!/usr/bin/env bash
# author: daniel rode
# dependencies:
#   bash 4+
# created: 01 jan 2026
# updated: -


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Shell settings
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

set -e  # Exit on error
set -x  # Echo script lines as they are executed
set -o pipefail  # Prevent tee from swallowing upstream exit codes


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# Workflow CPU priority
NICENESS=15

# Configure container
CON_IMG=CONTAINER_IMAGE_NAME
CON_SETTINGS=(
    --rm
    --interactive --tty
    --volume /etc/localtime:/etc/localtime:ro
    --volume /mnt:/mnt:ro
    --volume /home:/home:ro
    --volume "$PWD:$PWD"
    --workdir "$PWD"
    "$CON_IMG"
)


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# Set working directory to where this script is
cd "$(dirname "$0")"

# Ensure directory for logs exists
mkdir -p ./logs

# Run workflow
nice --adjustment "$NICENESS" \
    podman run "${CON_SETTINGS[@]}" "$@" \
|& tee "./logs/$(basename "$1").log"
