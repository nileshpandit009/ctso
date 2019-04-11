#!/bin/bash

# Install Fabric
function installFabric() {
	echo ''
	echo '########## This may take a while... ##########'
	mkdir -v $MY_DIR/hyperledger-fabric && cd $MY_DIR/hyperledger-fabric && \
	curl -sSL http://bit.ly/2ysbOFE | bash -s 1.3.0 && \
	echo 'export PATH=$PATH:$PWD/fabric-samples/bin' >> $HOME/.bashrc && \
	echo '########## Fabric installed successfully ##########' || \
	echo '!!!!!!!!!! Fabric installation failed !!!!!!!!!!'
}

# Update repositories
sudo apt update -y

# Install cURL
sudo apt install curl -y

# Installing Hyperledger-composer prerequisites
curl -O https://hyperledger.github.io/composer/latest/prereqs-ubuntu.sh
chmod u+x prereqs-ubuntu.sh
./prereqs-ubuntu.sh

echo ''
echo '#########################################'
echo '### Installed Git, Node, npm, Docker, ###'
echo '### Docker Compose, Python v2         ###'
echo '#########################################'
echo ''

# Make a new directory and proceed further
export MY_DIR=$HOME/blockchain
mkdir -v $MY_DIR && cd $MY_DIR

# Download and install Go 1.10.7
wget "https://dl.google.com/go/go1.10.7.linux-amd64.tar.gz" -c -t 0 && \
	tar -xf go1.10.*.tar.gz -C $HOME/ && \
	echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc && \
	echo 'export PATH=$PATH:$GOPATH/bin' >> $HOME/.bashrc && \
	echo '########## Go v1.10.7 installed successfully ##########'

# Confirm npm version by installing
source ~/.profile
npm install npm@5.6.0 -g


########################################################
#### Prepare to install Fabric and Log the user out ####
########################################################

cat > $HOME/.config/upstart/fabric_continue.conf << "EOF"
start on startup
task
exec gnome-terminal --window --command "$HOME/fabric_continue.sh"
EOF

cat > $HOME/fabric_continue.sh << "EOF"

export MY_DIR=$HOME/blockchain
echo ''
echo '########## This may take a while... ##########'
mkdir -v $MY_DIR/hyperledger-fabric && cd $MY_DIR/hyperledger-fabric && \
curl -sSL http://bit.ly/2ysbOFE | bash -s 1.3.0 && \
echo 'export PATH=$PATH:$PWD/fabric-samples/bin' >> $HOME/.bashrc && \
echo '########## Fabric installed successfully ##########' && \
touch $MY_DIR/fabric_install_success || \
touch $MY_DIR/fabric_install_failed || \
echo '!!!!!!!!!! Fabric installation failed !!!!!!!!!!'

rm -vf $HOME/.config/upstart/fabric_continue.conf
rm -vf $HOME/fabric_continue.sh

sleep 20s

exit
EOF

chmod u+x $HOME/fabric_continue.sh

echo 'You will be logged out in 5 seconds...'
echo 'Please login again for further execution.'
sleep 5
gnome-session-quit --logout --no-prompt


