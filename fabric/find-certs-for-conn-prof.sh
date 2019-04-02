#!/bin/bash

rm -rf ./certs
mkdir -v ./certs
for n in {0..3}
do 
	awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/citysurvey.gov/orderers/orderer$n.citysurvey.gov/tls/ca.crt > \
		./certs/orderer$n
	awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.citysurvey.gov/peers/peer$n.org1.citysurvey.gov/tls/ca.crt > \
		./certs/peer$n
done

