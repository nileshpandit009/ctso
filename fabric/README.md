## Basic Network Config

Steps:

0.	Set proper values for environment variables in .env file.
1.	Source the .env file by ``source .env``.
2.	Initialize swarm by ``docker swarm init`` and join other nodes by following instructions on terminal.
3.	Create an overlay network by ``docker network create --attachable --driver overlay --subnet=10.200.1.0/24 ctso``.
4.	Generate configuration transactions (configtx) and crypto material using ``start.sh generate.sh``.
5.	<b>Don't forget to copy the configtx and crypto material on other hosts.</b>
6.	Start the fabric using ``start.sh up`` (You can monitor the stack using ``docker stack ps ctso``).
7.	Delete any previous composer cards and delete .composer by ``rm -rf ~/.composer/``.
8.	Goto the ``composer`` directory and run ``replaceVariables.sh`` and ``./createPeerAdminCard.sh``.
9.	Install business network on fabric using ``composer network install`` command.
10.	Request new identities using ``composer identity request`` command.
11.	Start the business network using ``composer network start`` command.
12. Create admin cards for both organizations using ``composer card create`` command.
13.	Import the newly created cards using ``composer card import`` command.
14.	Ping the network using ``composer network ping`` command.

PS:	Refer ``cmd.history`` file for usage of above mentioned commands.
	<b>DEPRICATED:
		``generate.sh``
		``run.sh``
		``set-env.sh``
		``find-certs-for-conn-prof.sh``</b>