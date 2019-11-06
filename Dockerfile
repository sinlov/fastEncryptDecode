# This dockerfile uses extends image https://hub.docker.com/sinlov/go-micro-cli
# VERSION 1
# Author: sinlov
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/golang?tab=description
FROM golang:1.13.3-stretch

COPY $PWD /usr/src/myapp
WORKDIR /usr/src/myapp
RUN make initDockerDevImages

#ENTRYPOINT [ "go", "env" ]
