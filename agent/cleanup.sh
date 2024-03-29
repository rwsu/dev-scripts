#!/usr/bin/env bash
set -x

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

LOGDIR=${SCRIPTDIR}/logs
source $SCRIPTDIR/logging.sh
source $SCRIPTDIR/common.sh
source $SCRIPTDIR/utils.sh
source $SCRIPTDIR/validation.sh
source $SCRIPTDIR/agent/common.sh

early_cleanup_validation

rm -rf "${OCP_DIR}/manifests"
rm -rf "${OCP_DIR}/output"

case "${AGENT_E2E_TEST_BOOT_MODE}" in
  "PXE" )
    sudo pkill agentpxeserver || true
    rm -rf ${WORKING_DIR}/boot-artifacts
    ;;
  "DISKIMAGE" )
    sudo rm -rf "${OCP_DIR}/cache"
    sudo rm -rf "${OCP_DIR}/temp"
    sudo podman rmi -f ${APPLIANCE_IMAGE} || true
    ;;
esac

sudo podman rm -f extlb || true
sudo rm ${WORKING_DIR}/haproxy.* || true
sudo firewall-cmd --zone libvirt --remove-port=${MACHINE_CONFIG_SERVER_PORT}/tcp
sudo firewall-cmd --zone libvirt --remove-port=${KUBE_API_PORT}/tcp
sudo firewall-cmd --zone libvirt --remove-port=${INGRESS_ROUTER_PORT}/tcp

if [[ $NUM_MASTERS == 1 && $IP_STACK == "v6" ]]; then
    sudo sed -i "/${AGENT_NODE0_IPSV6} console-openshift-console.apps.${CLUSTER_DOMAIN}/d" /etc/hosts
    sudo sed -i "/${AGENT_NODE0_IPSV6} oauth-openshift.apps.${CLUSTER_DOMAIN}/d" /etc/hosts
    sudo sed -i "/${AGENT_NODE0_IPSV6} thanos-querier-openshift-monitoring.apps.${CLUSTER_DOMAIN}/d" /etc/hosts
fi

if [[ "${NODES_PLATFORM}" == "vsphere" ]]; then
    set +x
    export GOVC_URL=$VSPHERE_VCENTER_SERVER
    export GOVC_USERNAME=$VSPHERE_VCENTER_USERNAME
    export GOVC_PASSWORD=$VSPHERE_VCENTER_PASSWORD
    export GOVC_INSECURE=true
    export GOVC_DATASTORE=$VSPHERE_FAILUREDOMAIN_DATASTORE_PATH
    export ISO="iso/${VSPHERE_VCENTER_USERNAME}/agent.x86_64.iso"
    set -x

    set +e
    for node in ${AGENT_NODES_HOSTNAMES//,/ }
    do
        govc vm.destroy $node
    done

    govc datastore.rm -ds $GOVC_DATASTORE $ISO 
    govc datastore.rm -ds $GOVC_DATASTORE "iso/${VSPHERE_VCENTER_USERNAME}" 
    set -e
fi