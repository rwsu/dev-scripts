#!/usr/bin/env bash
set -euxo pipefail

export AGENT_STATIC_IP_NODE0_ONLY=${AGENT_STATIC_IP_NODE0_ONLY:-"false"}
export AGENT_NMSTATE_DHCP=${AGENT_NMSTATE_DHCP:-"false"}

export AGENT_USE_ZTP_MANIFESTS=${AGENT_USE_ZTP_MANIFESTS:-"false"}

export AGENT_USE_APPLIANCE_MODEL=${AGENT_USE_APPLIANCE_MODEL:-"false"}
export AGENT_APPLIANCE_HOTPLUG=${AGENT_APPLIANCE_HOTPLUG:-"false"}
export AGENT_PLATFORM_TYPE=${AGENT_PLATFORM_TYPE:-"baremetal"}
export AGENT_PLATFORM_NAME=${AGENT_PLATFORM_NAME:-"oci"}

export AGENT_BM_HOSTS_IN_INSTALL_CONFIG=${AGENT_BM_HOSTS_IN_INSTALL_CONFIG:-"false"}

export BOND_CONFIG=${BOND_CONFIG:-"none"}

# Image reference for OpenShift-based Appliance Builder.
# See: https://github.com/openshift/appliance
export APPLIANCE_IMAGE=${APPLIANCE_IMAGE:-"quay.io/edge-infrastructure/openshift-appliance:latest"}

# Override command name in case of extraction
export OPENSHIFT_INSTALLER_CMD="openshift-install"

# Location of extra manifests
export EXTRA_MANIFESTS_PATH="${OCP_DIR}/openshift"

# Set required config vars for PXE boot mode
if [[ "${AGENT_E2E_TEST_BOOT_MODE}" == "PXE" ]]; then
  export PXE_SERVER_DIR=${WORKING_DIR}/boot-artifacts
  export PXE_SERVER_URL=http://$(wrap_if_ipv6 ${PROVISIONING_HOST_EXTERNAL_IP}):${AGENT_PXE_SERVER_PORT}
  export PXE_BOOT_FILE=agent.x86_64.ipxe
fi

function getReleaseImage() {
    local releaseImage=${OPENSHIFT_RELEASE_IMAGE}
    if [ ! -z "${MIRROR_IMAGES}" ]; then
        releaseImage="${OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE}"
    # If not installing from src, let's use the current version from the binary
    elif [ -z "$KNI_INSTALL_FROM_GIT" ]; then
      local openshift_install="$(realpath "${OCP_DIR}/openshift-install")"
      releaseImage=$("${openshift_install}" --dir="${OCP_DIR}" version | grep "release image" | cut -d " " -f 3)      
    fi
    echo ${releaseImage}
}

# External load balancer configuration.
# The following ports are opened in firewalld so that libvirt VMs can communicate with haproxy.
export MACHINE_CONFIG_SERVER_PORT=22623
export KUBE_API_PORT=6443
export INGRESS_ROUTER_PORT=443
export AGENT_NODE0_IPSV6=${AGENT_NODE0_IPSV6:-}

# vSphere configuration
export VSPHERE_VCENTER_DATACENTER=${VSPHERE_VCENTER_DATACENTER:-"testDatacenter"}
export VSPHERE_VCENTER_SERVER=${VSPHERE_VCENTER_SERVER:-"vcenter.test.com"}
export VSPHERE_VCENTER_USERNAME=${VSPHERE_VCENTER_USERNAME:-"testUser@vcenter.test.com"}
export VSPHERE_VCENTER_PASSWORD=${VSPHERE_VCENTER_PASSWORD:-"testPassword"}
export VSPHERE_FAILUREDOMAIN_NAME=${VSPHERE_FAILUREDOMAIN_NAME:-"failure-domain-1"}
export VSPHERE_FAILUREDOMAIN_REGION=${VSPHERE_FAILUREDOMAIN_REGION:-"region1"}
export VSPHERE_FAILUREDOMAIN_ZONE=${VSPHERE_FAILUREDOMAIN_ZONE:-"zone1"}
export VSPHERE_FAILUREDOMAIN_DATASTORE_PATH=${VSPHERE_FAILUREDOMAIN_DATASTORE_PATH:-"/testDatacenter/datastore/testDatastore"}
export VSPHERE_FAILUREDOMAIN_COMPUTE_CLUSTER=${VSPHERE_FAILUREDOMAIN_COMPUTE_CLUSTER:-"/testDatacenter/host/testClusters"}
export VSPHERE_FAILUREDOMAIN_FOLDER_PATH=${VSPHERE_FAILUREDOMAIN_FOLDER_PATH:-"/testDatacenter/vm/testFolder"}
export VSPHERE_FAILUREDOMAIN_NETWORK=${VSPHERE_FAILUREDOMAIN_NETWORK:-"testNetwork"}