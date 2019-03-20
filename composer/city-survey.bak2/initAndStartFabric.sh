#!/bin/sh

export FABRIC_VERSION=hlfv12
export FABRIC_START_TIMEOUT=15

echo "Starting fabric with default config"

/home/nilesh/Blockchain/Hyperledger/fabric-dev-servers/startFabric.sh

echo "Creating PeerAdmin card"
/home/nilesh/Blockchain/Hyperledger/fabric-dev-servers/createPeerAdminCard.sh
