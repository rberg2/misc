#!/bin/bash

cleanup() {
    if [ -e ~/batches.intkey ]; then
        rm -f ~/batches.intkey
    fi

    if [ -e ~/config-genesis.batch ]; then
        rm -f ~/config-genesis.batch
    fi

    rm -rf ~/.sawtooth
    sudo rm -rf /etc/sawtooth/keys/*
    sudo bash -c 'rm -rf /var/lib/sawtooth/*'
}

if [ "$(ls -1 ~/.sawtooth/keys | wc -l)" -ne 2 ]; then
    sawtooth keygen
fi

if ! [ -e ~/config-genesis.batch ]; then
    sawset genesis
fi

if ! sudo test -e /var/lib/sawtooth/genesis.batch; then
    sudo -u sawtooth sawadm genesis config-genesis.batch
fi

if sudo test -e /var/lib/sawtooth/block-00.lmdb; then
    sudo rm -rf /var/lib/sawtooth/genesis.batch
fi

if [ "$(ls -1 /etc/sawtooth/keys | wc -l)" -ne 2 ]; then
    sudo sawadm keygen
fi

tmux new-session -d -s sawtooth 'exec sudo -u sawtooth sawtooth-validator -vv'
tmux rename-window 'sawtooth'
tmux select-window -t sawtooth:0
tmux split-window -v 'exec sudo -u sawtooth sawtooth-rest-api -v'
tmux split-window -v -t 1 'exec sudo -u sawtooth intkey-tp-python -v'
tmux split-window -v -t 1 'exec sudo -u sawtooth settings-tp -v'
tmux split-window -v -t 2
tmux -2 attach-session -t sawtooth
