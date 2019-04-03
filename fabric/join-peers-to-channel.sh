#!/bin/bash

CLI=$(docker ps --format="{{.Names}}" | grep -i cli)
echo $CLI

PEER_ORG1=$(docker ps --format="{{.Names}}" | grep -i 'peer[0-4]_org1')
echo $PEER_ORG1

PEER_ORG2=$(docker ps --format="{{.Names}}" | grep -i 'peer[0-4]_org2')
echo $PEER_ORG2

function printHelp() {
	echo ''
	echo 'Usage: join-peers-to-channel.sh <mode>'
	echo ''
	echo '	<mode>	- One of the following'
	echo '		- create 	: create the channel on cli container'
	echo '		- join 		: join the peers to the channel'
}

function createChannel() {
	###############################################
	############### Create Channel ################
	###############################################
	set -x
	docker exec ${CLI} peer channel create -o orderer0.citysurvey.gov:7050 -c ctsochan -f /opt/gopath/src/github.com/hyperledger/fabric/peer/config/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/citysurvey.gov/users/Admin@citysurvey.gov/msp/tlscacerts/tlsca.citysurvey.gov-cert.pem --timeout 15s
	set +x
	if [ "$?" -ne 0 ]; then
		echo "ERROR: Create channel ${CLI}"
		exit 1
	fi
}

function joinPeersToChannel() {
	###############################################
	########### Fetch and Join Channel ############
	###############################################
	set -x
	docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/users/Admin@org1.citysurvey.gov/msp" ${PEER_ORG1} peer channel fetch config -o orderer0.citysurvey.gov:7050 -c ctsochan --tls --cafile /etc/hyperledger/orderers/users/Admin@citysurvey.gov/msp/tlscacerts/tlsca.citysurvey.gov-cert.pem 
	set +x
	if [ "$?" -ne 0 ]; then
		echo "ERROR: Fetch channel ${PEER_ORG1}"
		exit 1
	fi

	set -x
	docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/users/Admin@org1.citysurvey.gov/msp" ${PEER_ORG1} peer channel join -b ctsochan_config.block --tls --cafile /etc/hyperledger/orderers/users/Admin@citysurvey.gov/msp/tlscacerts/tlsca.citysurvey.gov-cert.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo "ERROR: Join channel ${PEER_ORG1}"
		exit 1
	fi

	set -x
	docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/users/Admin@org2.citysurvey.gov/msp" ${PEER_ORG2} peer channel fetch config -o orderer0.citysurvey.gov:7050 -c ctsochan --tls --cafile /etc/hyperledger/orderers/users/Admin@citysurvey.gov/msp/tlscacerts/tlsca.citysurvey.gov-cert.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo "ERROR: Fetch channel ${PEER_ORG2}"
		exit 1
	fi

	set -x
	docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/users/Admin@org2.citysurvey.gov/msp" ${PEER_ORG2} peer channel join -b ctsochan_config.block --tls --cafile /etc/hyperledger/orderers/users/Admin@citysurvey.gov/msp/tlscacerts/tlsca.citysurvey.gov-cert.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo "ERROR: Join channel ${PEER_ORG2}"
		exit 1
	fi
}

MODE=$1

if [ "$MODE" == "create" ]; then
	createChannel
elif [ "$MODE" == "join" ]; then
	joinPeersToChannel
else
	printHelp
fi
