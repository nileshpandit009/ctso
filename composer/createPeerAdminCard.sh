#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Usage() {
	echo ""
	echo "Usage: ./createPeerAdminCard.sh [-h host] [-n] [-d dir]"
	echo ""
	echo "Options:"
    echo -e "\t-d or --projectdirectory:\tSpecify project directory"
	echo -e "\t-h or --host:\t\t(Optional) name of the host to specify in the connection profile"
	echo -e "\t-n or --noimport:\t(Optional) don't import into card store"
	echo ""
	echo "Example: ./createPeerAdminCard.sh"
	echo ""
	exit 1
}

Parse_Arguments() {
	while [ $# -gt 0 ]; do
		case $1 in
			--help)
				HELPINFO=true
				;;
			--host | -h)
                shift
				HOST="$1"
				;;
            --noimport | -n)
				NOIMPORT=true
				;;
            --projectdirectory | -d)
                shift
                PROJECT_DIR="$1"
		esac
		shift
	done
}

HOST=localhost
# Set project directory
PROJECT_DIR=/ctso
Parse_Arguments $@

if [ "${HELPINFO}" == "true" ]; then
    Usage
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${HL_COMPOSER_CLI}" ]; then
  HL_COMPOSER_CLI=$(which composer)
fi

echo
# check that the composer command exists at a version >v0.16
COMPOSER_VERSION=$("${HL_COMPOSER_CLI}" --version 2>/dev/null)
COMPOSER_RC=$?

if [ $COMPOSER_RC -eq 0 ]; then
    AWKRET=$(echo $COMPOSER_VERSION | awk -F. '{if ($2<20) print "1"; else print "0";}')
    if [ $AWKRET -eq 1 ]; then
        echo Cannot use $COMPOSER_VERSION version of composer with fabric 1.2, v0.20 or higher is required
        exit 1
    else
        echo Using composer-cli at $COMPOSER_VERSION
    fi
else
    echo 'No version of composer-cli has been detected, you need to install composer-cli at v0.20 or higher'
    exit 1
fi


if [ "${NOIMPORT}" != "true" ]; then
    CARD1OUTPUT=/tmp/PeerAdminOrg1@ctso.card
    CARD2OUTPUT=/tmp/PeerAdminOrg2@ctso.card
else
    CARD1OUTPUT=PeerAdminOrg1@ctso.card
    CARD2OUTPUT=PeerAdminOrg2@ctso.card
fi


ORG1="${PROJECT_DIR}"/fabric/crypto-config/peerOrganizations/org1.citysurvey.gov/users/Admin@org1.citysurvey.gov/msp
ORG2="${PROJECT_DIR}"/fabric/crypto-config/peerOrganizations/org2.citysurvey.gov/users/Admin@org2.citysurvey.gov/msp

# Fetch key and cert names for org1
CUR_DIR=${PWD}
cd ${ORG1}/signcerts
CERT_NAME=$(ls A*.pem)
cd ../keystore
KEY_NAME=$(ls *_sk)
cd ${CUR_DIR}
CERT=${ORG1}/signcerts/${CERT_NAME}
PRIVATE_KEY=${ORG1}/keystore/${KEY_NAME}

# Create PeerAdmin cards for Org1
"${HL_COMPOSER_CLI}"  card create -p connection-profile-org1.json -u PeerAdminOrg1 -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARD1OUTPUT

# Fetch key and cert names for org2
CUR_DIR=${PWD}
cd ${ORG2}/signcerts
CERT_NAME=$(ls A*.pem)
cd ../keystore
KEY_NAME=$(ls *_sk)
cd ${CUR_DIR}
CERT=${ORG2}/signcerts/${CERT_NAME}
PRIVATE_KEY=${ORG2}/keystore/${KEY_NAME}

# Create PeerAdmin cards for Org2
"${HL_COMPOSER_CLI}"  card create -p connection-profile-org2.json -u PeerAdminOrg2 -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARD2OUTPUT


if [ "${NOIMPORT}" != "true" ]; then
    if "${HL_COMPOSER_CLI}"  card list -c PeerAdminOrg1@ctso > /dev/null; then
        "${HL_COMPOSER_CLI}"  card delete -c PeerAdminOrg1@ctso
    fi

    if "${HL_COMPOSER_CLI}"  card list -c PeerAdminOrg2@ctso > /dev/null; then
        "${HL_COMPOSER_CLI}"  card delete -c PeerAdminOrg2@ctso
    fi

    "${HL_COMPOSER_CLI}"  card import --file /tmp/PeerAdminOrg1@ctso.card 
    "${HL_COMPOSER_CLI}"  card import --file /tmp/PeerAdminOrg2@ctso.card 
    "${HL_COMPOSER_CLI}"  card list
    echo "Hyperledger Composer PeerAdmin card has been imported, host of fabric specified as '${HOST}'"
    rm /tmp/PeerAdminOrg1@ctso.card
    rm /tmp/PeerAdminOrg2@ctso.card
else
    echo "Hyperledger Composer PeerAdmin card has been created, host of fabric specified as '${HOST}'"
fi
