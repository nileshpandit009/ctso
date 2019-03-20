#!/bin/sh

echo "**********Installing city survey network**********"

composer network install --archiveFile ./dist/city-survey.bna --card PeerAdmin@hlfv1

echo "**********Starting city survey network**********"

composer network start --networkName city-survey --networkVersion 0.0.1 --networkAdmin admin --networkAdminEnrollSecret adminpw --card PeerAdmin@hlfv1 --file networkadmin.card

echo "**********Import and ping admin card**********"

composer card import --file networkadmin.card 
composer network ping --card admin@city-survey
