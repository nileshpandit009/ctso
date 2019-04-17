#/bin/bash

function replacePrivateKey() {
    OPTS="-i"

    # Copy the template to the file that will be modified.
    # cp -vT connection-profile-template.json connection-profile-org1.json connection-profile-org2.json

    # for f in {1,2}; do
    #     cp -vT connection-profile-template.json connection-profile-org$f.json
    # done

    ORG1_NAME=Org1
    ORG2_NAME=Org2

    IP_NODE1=192.168.43.200
    IP_NODE2=192.168.43.210
    IP_NODE3=192.168.43.220
    IP_NODE4=192.168.43.230

    PEER_ORG1_CA=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $PROJECT_DIR/fabric/crypto-config/peerOrganizations/org1.citysurvey.gov/peers/peer0.org1.citysurvey.gov/tls/ca.crt)
    PEER_ORG2_CA=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $PROJECT_DIR/fabric/crypto-config/peerOrganizations/org2.citysurvey.gov/peers/peer0.org2.citysurvey.gov/tls/ca.crt)
    ORDERER_CA=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $PROJECT_DIR/fabric/crypto-config/ordererOrganizations/citysurvey.gov/orderers/orderer0.citysurvey.gov/tls/ca.crt)

    export ORG1_NAME ORG2_NAME IP_NODE1 IP_NODE2 IP_NODE3 IP_NODE4 PEER_ORG1_CA PEER_ORG2_CA ORDERER_CA

    # sed $OPTS "s/ORG_NAME/${ORG1_NAME}/g" connection-profile-org1.json
    # sed $OPTS "s/ORG_NAME/${ORG2_NAME}/g" connection-profile-org2.json

    # sed $OPTS "s/IP_NODE1/${IP_NODE1}/g" connection-profile-org{1,2}.json
    # sed $OPTS "s/IP_NODE2/${IP_NODE2}/g" connection-profile-org{1,2}.json
    # sed $OPTS "s/IP_NODE3/${IP_NODE3}/g" connection-profile-org{1,2}.json
    # sed $OPTS "s/IP_NODE4/${IP_NODE4}/g" connection-profile-org{1,2}.json
 
    perl -p -e 's/ORG_NAME/$ENV{ORG1_NAME}/g;s/IP_NODE1/$ENV{IP_NODE1}/g;s/IP_NODE2/$ENV{IP_NODE2}/g;s/IP_NODE3/$ENV{IP_NODE3}/g;s/IP_NODE4/$ENV{IP_NODE4}/g;s/PEER_ORG1_CA/$ENV{PEER_ORG1_CA}/g;s/PEER_ORG2_CA/$ENV{PEER_ORG2_CA}/g;s/ORDERER_CA/$ENV{ORDERER_CA}/g' connection-profile-template.json > connection-profile-org1.json
    perl -p -e 's/ORG_NAME/$ENV{ORG2_NAME}/g;s/IP_NODE1/$ENV{IP_NODE1}/g;s/IP_NODE2/$ENV{IP_NODE2}/g;s/IP_NODE3/$ENV{IP_NODE3}/g;s/IP_NODE4/$ENV{IP_NODE4}/g;s/PEER_ORG1_CA/$ENV{PEER_ORG1_CA}/g;s/PEER_ORG2_CA/$ENV{PEER_ORG2_CA}/g;s/ORDERER_CA/$ENV{ORDERER_CA}/g' connection-profile-template.json > connection-profile-org2.json

#     sed $OPTS "s%PEER_ORG1_CA%$PEER_ORG1_CA%g" connection-profile-org{1,2}.json
#     sed $OPTS "s%PEER_ORG2_CA%$PEER_ORG2_CA%g" connection-profile-org{1,2}.json
#     sed $OPTS "s%ORDERER_CA%$ORDERER_CA%g" connection-profile-org{1,2}.json
}

set -a
source .env
set +a

PROJECT_DIR=/ctso

rm -f connection-profile-org{1,2}.json
replacePrivateKey