## HOWTO get started? Like so...

Steps:

0.	Set proper values for environment variables in .env file.
1.	Source the .env file by ``source .env``.
2.	Initialize swarm by ``docker swarm init`` and join other nodes by following instructions on terminal.
3.	Create an overlay network by ``docker network create --attachable --driver overlay --subnet=10.200.1.0/24 ctso``.
4.	Generate configuration transactions (configtx) and crypto material using ``start.sh generate``.
5.	<b>Don't forget to copy the configtx and crypto material on other hosts.</b>
6.	Start the fabric using ``start.sh up`` (You can monitor the stack using ``docker stack ps ctso``).
7.	Create channel using ``join-peers-to-channel.sh create``.
8.	Join peers to this channel using ``join-peers-to-channel.sh join``.
9.	Delete any previous composer cards and delete .composer directory by ``rm -rf ~/.composer/``.
10.	Goto the ``composer`` directory and run ``replaceVariables.sh`` and ``./createPeerAdminCard.sh``.
11.	Install business network on fabric using ``composer network install`` command.
12.	Request new identities using ``composer identity request`` command.
13.	Start the business network using ``composer network start`` command.
14. Create admin cards for both organizations using ``composer card create`` command.
15.	Import the newly created cards using ``composer card import`` command.
16.	Ping the network using ``composer network ping`` command.
17.	Create RESTful API using the following command
	``composer-rest-server -c adminorg1@city-survey -n always -u true -w true -t true -e $HOME/.nvm/versions/node/v8.15.0/lib/node_modules/composer-rest-server/cert.pem -k $HOME/.nvm/versions/node/v8.15.0/lib/node_modules/composer-rest-server/key.pem``

PS:	Refer ``cmd.history`` file for usage of above mentioned commands.
	<b>DEPRICATED:
		``generate.sh``
		``run.sh``
		``set-env.sh``
		``find-certs-for-conn-prof.sh``</b>
