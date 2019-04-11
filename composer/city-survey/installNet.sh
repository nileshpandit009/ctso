composer archive create --sourceType dir --sourceName . -a ./city-survey.bna
composer network install -a city-survey.bna -c PeerAdmin@hlfv1 
composer network start -c PeerAdmin@hlfv1 -n city-survey -V 0.0.1 -A admin -S adminpw -f networkadmin.card
composer card import -f networkadmin.card
