#!/bin/bash

mkdir -p /opt/root/go_libs

if [ -n "${SSH_USER}" ]; then

    mkdir -p /opt/${SSH_USER}/go_libs
    chown -R ${SSH_USER}:${SSH_USER} /opt/${SSH_USER}
fi
