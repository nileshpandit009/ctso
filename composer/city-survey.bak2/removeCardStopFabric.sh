#!/bin/sh

export FABRIC_VERSION=hlfv12

echo "Deleting network cards"

composer card delete -c PeerAdmin@hlfv1
composer card delete -c admin@city-survey

echo "Stopping Fabric"

/home/nilesh/Blockchain/Hyperledger/fabric-dev-servers/stopFabric.sh

