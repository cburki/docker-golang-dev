#!/bin/bash

if [ ! -f /root/.gitconfig ]; then

    if [ -n "${GIT_EMAIL}" ]; then

        echo "Setting git email to ${GIT_EMAIL}"
        git config --global user.email "${GIT_EMAIL}"
    
        if [ -n "${SSH_USER}" ]; then
            cp /root/.gitconfig /home/${SSH_USER}/.
        fi
    fi

    if [ -n "${GIT_NAME}" ]; then

        echo "Setting git name to ${GIT_NAME}"
        git config --global user.name "${GIT_NAME}"
    
        if [ -n "${SSH_USER}" ]; then
            cp /root/.gitconfig /home/${SSH_USER}/.
        fi
    fi
fi

if [ ! -f /root/.ssh/id_rsa-git ]; then
    
    echo "Generating git key"
    cd /root/.ssh/
    if [ -z "${GIT_KEY_PASSPHRASE}" ]; then
        GIT_KEY_PASSPHRASE=$(pwgen -c -n -1 12)
        echo "New git key passphrase : ${GIT_KEY_PASSPHRASE}"
    fi
    ssh-keygen -t rsa -N ${GIT_KEY_PASSPHRASE} -f /root/.ssh/id_rsa-git
        
    if [ -n "${SSH_USER}" ]; then
        cp /root/.ssh/id_rsa-git* /home/${SSH_USER}/.ssh/.
    fi
fi

if [ -n "${GIT_HOSTS}" ]; then

    SSH_CONFIG=/root/.ssh/config
    
    if [ ! -f ${SSH_CONFIG} ]; then
    
        # GIT_HOSTS=user1@host1:port1,user2@host2:port2,...
        
        IFS="," read -ra hosts <<< ${GIT_HOSTS}
        for UHP in "${hosts[@]}"; do

            echo "Adding git host ${UHP}"
            IFS="@" read -ra uhp <<< ${UHP}
            user=${uhp[0]}
            IFS=":" read -ra hp <<< ${uhp[1]}
            host=${hp[0]}
            port=${hp[1]}

            echo "Host ${host}" >> ${SSH_CONFIG}
            echo "  Port ${port}" >> ${SSH_CONFIG}
            echo "  User ${user}" >> ${SSH_CONFIG}
            echo "  IdentityFile ~/.ssh/id_rsa-git" >> ${SSH_CONFIG}
            echo "" >> ${SSH_CONFIG}
        done
        
        if [ -n "${SSH_USER}" ]; then
            cp ${SSH_CONFIG} /home/${SSH_USER}/.ssh/.
        fi
    fi
fi

exit 0
