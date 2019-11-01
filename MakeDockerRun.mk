# this file must use as base Makefile

ROOT_DOCKER_CONTAINER ?= $(ROOT_NAME)
# change this for dockerRun
ROOT_DOCKER_IMAGE_PARENT_NAME ?= golang
ROOT_DOCKER_IMAGE_PARENT_TAG ?= 1.13.3-stretch
# change this for dockerRunLinux or dockerRunDarwin
ROOT_DOCKER_IMAGE_NAME ?= $(ROOT_NAME)
ROOT_DOCKER_IMAGE_TAG ?= $(DIST_VERSION)