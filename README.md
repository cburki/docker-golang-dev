Summary
-------

Docker image for go development with SSH server. This image is the golang official
plus a SSH server that let us connect to the container and build projects. The
codes of your projects are stored in a volume.


Build the image
---------------

To create this image, execute the following command in the docker-golang-dev folder.

    docker build \
        -t cburki/golang-dev \
        .
        

Run the image
-------------

To access the SSH server you need to bind the port 22. You could attach a data
volume container where your codes are stored. I'm using a data volume container
where my codes are synchronized with Google Drive using Insync (see docker-insync
image).

    docker run \
        --name golang-dev \
        --volumes-from golang-dev-data \
        -e SSH_PASSWORD=<your secret password> \
        -e SSH_AUTHORIZED_KEY=<your ssh public key> \
        -p <external port>:22 \
		-d \
        cburki/goland-dev:latest
