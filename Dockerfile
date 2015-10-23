FROM golang:latest
MAINTAINER Christophe Burki, christophe@burkionline.net

# Install system requirements
RUN apt-get update && apt-get install -y \
    emacs24-nox \
    locales \
    openssh-server \
    pwgen

# Configure locales and timezone
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 fr_CH.UTF-8
RUN cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN echo "Europe/Zurich" > /etc/timezone

# Configure sshd
RUN mkdir /var/run/sshd
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

# s6 install and config
COPY bin/* /usr/bin/
COPY configs/etc/s6 /etc/s6/

# install setup scripts
COPY scripts/* /opt/
RUN chmod a+x /opt/setupusers.sh

# add bash prompt and go path
RUN echo 'PS1="\[\e[00;36m\][\$?]\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;32m\]\u@\h\[\e[0m\]\[\e[00;30m\] \[\e[0m\]\[\e[00;34m\][\W]\[\e[0m\]\[\e[00;30m\] \\$ \[\e[0m\]"' >> /root/.bashrc
RUN echo "PATH=$PATH:/usr/local/go/bin" >> /root/.bashrc

EXPOSE 22

CMD ["/usr/bin/s6-svscan", "/etc/s6"]
