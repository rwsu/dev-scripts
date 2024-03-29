#!/usr/bin/env bash
set -euxo pipefail
source common.sh

# from 02_configure_host.sh
echo '{}' | sudo dd of=${REGISTRY_CREDS}
# Since podman 2.2.1 the REGISTRY_CREDS file gets written out as
# o600, where as in previous versions it was 644 - to enable reading
# as $USER elsewhere we chown here, but in future we should probably
# consider moving all podman calls to rootless mode (e.g remove sudo)
sudo chown $USER:$USER ${REGISTRY_CREDS}
ls -l ${REGISTRY_CREDS}