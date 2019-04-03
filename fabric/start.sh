#!/bin/bash

function replacePrivateKey() {
    OPTS="-i"

    rm -f fabric-ca-run.yml
    # Copy the template to the file that will be modified to add the private key
    cp fabric-ca.yml fabric-ca-run.yml

    # The next steps will replace the template's contents with the
    # actual values of the private key file names for the two CAs.
    CURRENT_DIR=$PWD
    cd crypto-config/peerOrganizations/org1.citysurvey.gov/ca/
    PRIV_KEY=$(ls *_sk)
    cd "$CURRENT_DIR"
    sed $OPTS "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" fabric-ca-run.yml
    cd crypto-config/peerOrganizations/org2.citysurvey.gov/ca/
    PRIV_KEY=$(ls *_sk)
    cd "$CURRENT_DIR"
    sed $OPTS "s/CA2_PRIVATE_KEY/${PRIV_KEY}/g" fabric-ca-run.yml
}

function generateCerts() {
	rm -fr ./crypto-config/*

    # generate crypto material
    cryptogen generate --config=./crypto-config.yaml
    if [ "$?" -ne 0 ]; then
      echo "Failed to generate crypto material..."
      exit 1
    fi
}

function generateConfigTx() {
    CHANNEL_NAME=ctsochan

    # remove previous crypto material and config transactions
    rm -fr ./config/*

    # generate genesis block for orderer
    configtxgen -profile TwoOrgOrdererGenesis -outputBlock ./config/genesis.block
    if [ "$?" -ne 0 ]; then
      echo "Failed to generate orderer genesis block..."
      exit 1
    fi

    # generate channel configuration transaction
    configtxgen -profile TwoOrgChannel -outputCreateChannelTx ./config/channel.tx -channelID $CHANNEL_NAME
    if [ "$?" -ne 0 ]; then
      echo "Failed to generate channel configuration transaction..."
      exit 1
    fi

    # generate anchor peer transaction
    configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
    if [ "$?" -ne 0 ]; then
      echo "Failed to generate anchor peer update for Org1MSP..."
      exit 1
    fi

    configtxgen -profile TwoOrgChannel -outputAnchorPeersUpdate ./config/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
    if [ "$?" -ne 0 ]; then
      echo "Failed to generate anchor peer update for Org1MSP..."
      exit 1
    fi
}

function deployServices() {
	if [ ! -d "config" ] || [ ! "$(ls -A config)" ]; then
		echo 'Crypto material not found!!!'
		exit 1
	else
		set -x
		docker stack deploy -c fabric-zk.yml $SWARM_NETWORK
    	docker stack deploy -c fabric-kafka.yml $SWARM_NETWORK
	    docker stack deploy -c fabric-orderer.yml $SWARM_NETWORK
	    docker stack deploy -c fabric-couchdb.yml $SWARM_NETWORK
    	docker stack deploy -c fabric-peer.yml $SWARM_NETWORK
	    docker stack deploy -c fabric-ca-run.yml $SWARM_NETWORK
	   	docker stack deploy -c fabric-cli.yml $SWARM_NETWORK
	   	set +x
	fi
}

function removeServices() {
	docker stack rm $SWARM_NETWORK
}

function printHelp() {
	echo ''
	echo 'Usage: ctso.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>]'
	echo '	<mode>  - one of the following'
	echo '		- up - bring up the network'
	echo '		- down - bring down the network'
	echo '		- generate - generate crypto materials and transactions'
	echo ''
	echo '	Options:'
	echo '		-h			: Print this help'
	echo '		-n <swarm network>	: Specify name of swarm network'
	echo '		-c <channel name>	: Specify name of channel'
	echo '		-t <timeout>		: Specify CLI timeout duration in seconds'
	echo '		-d <delay>		: Specify delay duration in seconds'
}


# Source the .env file
set -a
source .env
set +a


# Default values for variables
SWARM_NETWORK=ctso
CHANNEL_NAME=ctsochan
CLI_TIMEOUT=15
CLI_DELAY=5

MODE=$1

if [ "$MODE" == "up" ]; then
	EXPMODE="Starting"
elif [ "$MODE" == "down" ]; then
	EXPMODE="Stopping"
elif [ "$MODE" == "generate" ]; then
	EXPMODE="Generating certs and genesis block"
else
	printHelp
	exit 1
fi

while getopts "h?n:c:t:d" opt; do
	case "$opt" in
	h | \?)
		printHelp
		exit 0
		;;
	n)
		SWARM_NETWORK=$OPTARG
		;;
	c)
		CHANNEL_NAME=$OPTARG
		;;
	t)
		CLI_TIMEOUT=$OPTARG
		;;
	d)
		CLI_DELAY=$OPTARG
	esac
done

# Create the network
if [ "$MODE" == "up" ]; then
	echo $EXPMODE
	deployServices
elif [ "$MODE" == "down" ]; then
	echo $EXPMODE
	removeServices
elif [ "$MODE" == "generate" ]; then
	echo $EXPMODE
	generateCerts
	generateConfigTx
	replacePrivateKey
else
	printHelp
	exit 1
fi
