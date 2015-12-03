#!/bin/bash

USER_STATUS_FILE=/opt/setupuser.status

if [ -f ${USER_STATUS_FILE} ]; then
    exit 0
fi


if [ -n "${SSH_PASSWORD}" ]; then
    echo "root:${SSH_PASSWORD}" | chpasswd
fi

if [ -n "${SSH_AUTHORIZED_KEY}" ]; then
    echo "${SSH_AUTHORIZED_KEY}" > /root/.ssh/authorized_keys
fi

if [ -n "${SSH_USER}" ]; then

    CREATED=/home/${SSH_USER}/.user-created
    
    if [ -f ${CREATED} ]; then
        exit 0
    fi

    groupadd -g 1000 ${SSH_USER}
    useradd -g 1000 -u 1000 -d /home/${SSH_USER} -m -k /etc/skel -s /bin/bash ${SSH_USER}
    
    if [ -z "${SSH_PASSWORD}" ]; then
        SSH_PASSWORD=$(pwgen -c -n -1 12)
        echo "New user password : ${SSH_PASSWORD}"
    fi
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd
    
    if [ -n "${SSH_AUTHORIZED_KEY}" ]; then
        mkdir -p /home/${SSH_USER}/.ssh
        echo "${SSH_AUTHORIZED_KEY}" > /home/${SSH_USER}/.ssh/authorized_keys
    fi
    
    if [ ! -f /home/${SSH_USER}/.bashrc ]; then
        cp /etc/skel/.bashrc /home/${SSH_USER}/.
        cp /etc/skel/.profile /home/${SSH_USER}/.
        echo 'PS1="\[\e[00;36m\][\$?]\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;32m\]\u@\h\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;34m\][\W]\[\e[0m\]\[\e[00;30m\] \\$ \[\e[0m\]"' >> /home/${SSH_USER}/.bashrc
        echo "PATH=$PATH:/usr/local/go/bin" >> /home/${SSH_USER}/.bashrc
    fi
    
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.bashrc
    chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.profile
    chown -R ${SSH_USER}:${SSH_USER} /home/${SSH_USER}/.ssh
    
    touch ${CREATED}
fi

echo "done" >> ${USER_STATUS_FILE}

exit 0
