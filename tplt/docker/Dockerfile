# author: Daniel Rode


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
# OR
# Install Ubuntu Linux packages
RUN ash <<EOF
set -e  # Exit on error
apt-get -y update
apt-get install -y --no-install-recommends \
    python3 \
;
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF

# Install binary dependencies other containers
COPY --from=ghcr.io/danielrode/CONTAINER:main \
    /usr/local/bin /usr/local/bin

ENV PATH="/usr/local/bin:$PATH"

# Install Python libraries using requirements.txt in cwd
RUN --mount=type=bind,source=requirements.txt,target=/tmp/deps.txt <<EOF
    # NOTE: The bind mount only persists for this step
    python3 -m pip install --no-cache-dir -r /tmp/deps.txt
EOF
