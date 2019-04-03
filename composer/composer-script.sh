#!/bin/bash

PROJECT_DIR=/ctso
COMPOSER_DIR=${PROJECT_DIR}/composer

function deleteBusinessCards() {
	rm -rf ~/.composer/
}

function createPeerAdminCards() {
	PROJECT_DIR=/ctso
	COMPOSER_DIR=${PROJECT_DIR}/composer

	${COMPOSER_DIR}/replaceVariables.sh
	${COMPOSER_DIR}/createPeerAdminCard.sh
}

function requestIdentities() {
	set -x
	composer identity request -c PeerAdminOrg1@ctso -u admin -s adminpw -d adminorg1
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Request identity using PeerAdminOrg1@ctso !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi
	set -x
	composer identity request -c PeerAdminOrg2@ctso -u admin -s adminpw -d adminorg2
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Request identity using PeerAdminOrg2@ctso !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	else
		echo '##################### Identities generated successfully #####################'
	fi
}

function installAndStartNetwork() {
	set -x
	composer network install -c PeerAdminOrg1@ctso -a city-survey/dist/city-survey.bna
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Network install using PeerAdminOrg1@ctso !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi
	set -x
	composer network install -c PeerAdminOrg2@ctso -a city-survey/dist/city-survey.bna
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Network install using PeerAdminOrg2@ctso !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	else
		echo '##################### Network installed successfully #####################'
	fi

	requestIdentities

	set -x
	composer network start -c PeerAdminOrg1@ctso --networkName city-survey --networkVersion 0.0.1 -o endorsement-policy.json -A adminorg1 -C adminorg1/admin-pub.pem -A adminorg2 -C adminorg2/admin-pub.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Network start failed !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi

	set -x
	composer card create -p connection-profile-org1.json -u adminorg1 -n city-survey -c adminorg1/admin-pub.pem -k adminorg1/admin-priv.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Create card for adminorg1 !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi
	set -x
	composer card create -p connection-profile-org2.json -u adminorg2 -n city-survey -c adminorg2/admin-pub.pem -k adminorg2/admin-priv.pem
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Create card for adminorg2 !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi

	set -x
	composer card import -f adminorg1@city-survey.card
	composer card import -f adminorg2@city-survey.card

	composer network ping -c adminorg1@city-survey
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Ping network using adminorg1 !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi
	set -x
	composer network ping -c adminorg2@city-survey
	set +x
	if [ "$?" -ne 0 ]; then
		echo '!!!!!!!!!!!!!!!!!!!!! Error: Ping network using adminorg1 !!!!!!!!!!!!!!!!!!!!!'
		exit 1
	fi
}

echo '@@@@@@@@@ Staring script composer commands @@@@@@@@@'

echo '@@@@@@@@@ Removing old business network cards @@@@@@@@@'
deleteBusinessCards
echo '@@@@@@@@@ Running wrapper script for replaceVariables.sh and createPeerAdminCard.sh @@@@@@@@@'
createPeerAdminCards
echo '@@@@@@@@@ Generating Identities and starting network @@@@@@@@@'
installAndStartNetwork