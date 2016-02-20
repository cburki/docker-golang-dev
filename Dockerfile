FROM golang:latest
MAINTAINER Christophe Burki, christophe.burki@gmail.com

# Install system requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    emacs24-nox \
    less \
    locales \
    openssh-server \
    pwgen && \
    apt-get autoremove -y && \
    apt-get clean

# Configure locales and timezone
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 fr_CH.UTF-8 && \
    cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime && \
    echo "Europe/Zurich" > /etc/timezone

# Configure sshd
RUN mkdir /var/run/sshd && \
    sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    mkdir /root/.ssh

# s6 install and configs
COPY bin/* /usr/bin/
COPY configs/etc/s6 /etc/s6/
RUN chmod a+x /usr/bin/s6-* && \
    chmod a+x /etc/s6/.s6-svscan/finish /etc/s6/sshd/run /etc/s6/sshd/finish

# install setup scripts
COPY scripts/* /opt/
RUN chmod a+x /opt/setupusers.sh /opt/setupgit.sh /opt/setupenv.sh

# add pager, bash prompt and go path
RUN echo 'PAGER=less' >> /root/.bashrc && \
    echo 'PS1="\[\e[00;36m\][\$?]\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;32m\]\u@\h\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;34m\][\W]\[\e[0m\]\[\e[00;30m\] \\$ \[\e[0m\]"' >> /root/.bashrc && \
    echo "PATH=$PATH:/usr/local/go/bin" >> /root/.bashrc

EXPOSE 22

CMD ["/usr/bin/s6-svscan", "/etc/s6"]
