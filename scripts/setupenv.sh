#!/bin/bash

mkdir -p /opt/root/go_libs

echo "PATH=$PATH:/usr/local/go/bin" >> /root/.bashrc
if [ -n "${SSH_USER}" ]; then
    mkdir -p /opt/${SSH_USER}/go_libs
    chown -R ${SSH_USER}:${SSH_USER} /opt/${SSH_USER}
    echo "PATH=$PATH:/usr/local/go/bin" >> /home/${SSH_USER}/.bashrc
fi
