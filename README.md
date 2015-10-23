Summary
-------

Docker image for go development with SSH server. This image is the golang official
plus a SSH server that let us connect to the container and build projects. The
codes of your projects are stored in a volume.


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
 
You will not be able to log into this container if you do not provide at
least SSH_PASSWORD or SSH_AUTHORIZED_KEY. Be careful to set a strong password
for the users because they have full access to the volumes you specify to mount
when running the container. When he user SSH_USER is created, the SSH_PASSWORD
and SSH_AUTHORIZED_KEY are also set for this user.
 

Run the image
-------------

To access the SSH server you need to bind the port 22. The directory where your
projects files reside could be mounted as a data volume.

    docker run \
        --name golang-dev \
        -v <projects folder>:/data \
        -e SSH_PASSWORD=<your secret password> \
        -e SSH_AUTHORIZED_KEY=<your ssh public key> \
        -p <external port>:22 \
		-d \
        cburki/goland-dev:latest

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
        -p <external port>:22 \
		-d \
        cburki/goland-dev:latest

Note that any other synchronization technology like dropbox, bittorrent sync, etc
can be used to synchronize your project files. Just embed your synchronization
tools in another container and attach the data volume container.