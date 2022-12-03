#!/usr/bin/env bash

WAX_VERSION=latest

# Home inside docker
NODEOS_HOME=/root/.local/share/eosio/nodeos

# WAX data folder root on the host running this docker image
HOST_WAX_HOME=${HOST_WAX_HOME:-`pwd`}

MAINNET_SNAPHOT=https://snapshots-cdn.eossweden.org/wax/2.0/latest

function start_from_snapshot {
  cd $HOST_WAX_HOME
  wget -O latest $MAINNET_SNAPHOT
  tar -xvzf latest
  rm latest*
  TGZ_FILES=( *.bin )
  SNAPSHOT="${TGZ_FILES[0]}"

  docker run -t --sig-proxy=true --name nodeos \
      -v $HOST_WAX_HOME:$NODEOS_HOME/data \
      -v $HOST_WAX_HOME:$NODEOS_HOME/config \
      -p 0.0.0.0:8888:8888 \
      -p 9876:9876 \
      waxteam/production:$WAX_VERSION \
      nodeos --verbose-http-errors --disable-replay-opts --snapshot $NODEOS_HOME/data/$SNAPSHOT
}
sudo chmod 666 /var/run/docker.sock
docker rm nodeos
sudo rm -rf $HOST_WAX_HOME/blocks
sudo rm -rf $HOST_WAX_HOME/protocol_features
sudo rm -rf $HOST_WAX_HOME/state
sudo rm -rf $HOST_WAX_HOME/sapshots
start_from_snapshot

