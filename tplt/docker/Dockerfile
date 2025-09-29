# Author: Daniel Rode


# https://docs.docker.com/reference/dockerfile/


FROM alpine:edge

LABEL Author="Daniel Rode"

# Install Alpine Linux packages
RUN ash <<EOF
set -e  # Exit on error
apk add --no-cache \
    R \
    bash \
    fd \
    gdal-tools \
    openssh \
    parallel \
    pdal \
    proj-util \
    python3 \
    udunits \
;
EOF

# Install binary dependencies other containers
COPY --from=ghcr.io/danielrode/CONTAINER:main \
    /usr/local/bin /usr/local/bin

ENV PATH="/usr/local/bin:$PATH"
