#!/usr/bin/env bash
# Dependencies:
#   bash 4+
# Created: 01 Oct 2025
# Updated: -


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
CON_IMG=CONTAINER_NAME
CON_SETTINGS=(
    --rm
    --interactive --tty
    --volume "/mnt:/mnt:ro"
    --volume "/home:/home:ro"
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

function main {
    # Run workflow
    echo "Starting $(date)"
    nice --adjustment "$NICENESS" podman run "${CON_SETTINGS[@]}" "$@"
    echo "Finished $(date)"
}
main "$@" &> ./main.log
