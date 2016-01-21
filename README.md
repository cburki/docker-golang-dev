Summary
-------

Docker image for go development with SSH server. This image is the golang official
plus a SSH server that let us connect to the container and build projects. The
codes of your projects are stored in a volume.

As the image is for development purpose, git is installed and usable. The git
email address and name recorded in any commits could be given in environment
variables when running the image. The git (ssh) key with it passphrase and
hosts where are located remote repositories could also be given in environment
variables.


Build the image
---------------

To create this image, execute the following command in the docker-golang-dev
folder.

    docker build \
        -t cburki/golang-dev \
        .


Configure the image
-------------------

The following environment variables could be used to configure the users.

 - SSH_PASSWORD : The password for root and given user. No password is set when not specified.
 - SSH_AUTHORIZED_KEY : Your public key that will be added to the authorized key file of the root and given user.
 - SSH_USER : An optional user that will be created.
 - GIT_EMAIL : The git email address recorded in any commits.
 - GIT_NAME : The git name recorded in any commits.
 - GIT_KEY_PASSPHRASE : The passphrase to protect the git key. A passphrase will be created for you if none is given.
 - GIT_HOSTS : The list of git hosts to connect to (user1@host1:port1,user2@host2:port2,...).
 
You will not be able to log into this container if you do not provide at
least SSH_PASSWORD or SSH_AUTHORIZED_KEY. Be careful to set a strong password
for the users because they have full access to the volumes you specify to mount
when running the container. When the user SSH_USER is created, the SSH_PASSWORD
and SSH_AUTHORIZED_KEY are also set for this user. If no SSH_PASSWORD is given
when creating the user, a password will be created for you. The new password
is written to the logs during the first startup.

If you do not want to use git simply do not fill the GIT_* variables. Otherwise
you need to fill them appropriately. If the use SSH_USER is created, the git
settings are pushed for this user too. Be careful to set a strong passphrase for
the git key because the key is used to push onto the remote repositories. The
generated key must be added into your repositories settings (github or gitlab).
To get the key you could execute the following command when the image is running.

    docker exec \
	    -i \
		-t \
		golang-dev \
		/bin/cat /root/.ssh/id_rsa-git.pub


Run the image
-------------

To access the SSH server you need to bind the port 22. The directory where your
projects files reside could be mounted as a data volume.

    docker run \
        --name golang-dev \
        -v <projects folder>:/data \
        -e SSH_PASSWORD=<your secret password> \
        -e SSH_AUTHORIZED_KEY=<your ssh public key> \
		-e GIT_EMAIL="<your git email address> \
		-e GIT_NAME="<your git name> \
		-e GIT_KEY_PASSPHRASE=<your secret passphrase> \
		-e GIT_HOSTS=user@host:port \
        -p <external port>:22 \
		-d \
        cburki/golang-dev:latest

When I'm not developping on my laptop, my development container is running on a
server and I'm using a data volume container where my codes are synchronized with
Google Drive using Insync (see cburki/insync image). You could also run your
development container and attach a data volume container where your codes are
stored.

    docker run \
        --name golang-dev \
        --volumes-from golang-dev-data \
        -e SSH_PASSWORD=<your secret password> \
        -e SSH_AUTHORIZED_KEY=<your ssh public key> \
		-e GIT_EMAIL="<your git email address> \
		-e GIT_NAME="<your git name> \
		-e GIT_KEY_PASSPHRASE=<your secret passphrase> \
		-e GIT_HOSTS=user@host:port \
        -p <external port>:22 \
		-d \
        cburki/golang-dev:latest

Note that any other synchronization technology like dropbox, bittorrent sync, etc
can be used to synchronize your project files. Just embed your synchronization
tools in another container and attach the data volume container.