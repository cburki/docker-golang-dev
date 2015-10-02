FROM golang:latest
MAINTAINER Christophe Burki, christophe@burkionline.net

# Install system requirements
RUN apt-get update && apt-get install -y \
    emacs24-nox \
    locales \
    openssh-server

# Configure locales and timezone
RUN locale-gen en_US.UTF-8
RUN locale-gen en_GB.UTF-8
RUN locale-gen fr_CH.UTF-8
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

# add go path
RUN echo "PATH=$PATH:/usr/local/go/bin" >> /root/.bashrc

EXPOSE 22

CMD ["/usr/bin/s6-svscan", "/etc/s6"]
