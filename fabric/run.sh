docker stack deploy -c fabric-zk.yml ctso
docker stack deploy -c fabric-kafka.yml ctso
docker stack deploy -c fabric-orderer.yml ctso
docker stack deploy -c fabric-couchdb.yml ctso
docker stack deploy -c fabric-peer.yml ctso
docker stack deploy -c fabric-ca.yml ctso
docker stack deploy -c fabric-cli.yml ctso
