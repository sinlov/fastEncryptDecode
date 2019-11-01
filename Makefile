.PHONY: test check clean build dist all

TOP_DIR := $(shell pwd)

# ifeq ($(FILE), $(wildcard $(FILE)))
# 	@ echo target file not found
# endif

DIST_VERSION := 1.0.0
# linux windows darwin  list as: go tool dist list
DIST_OS := linux
# amd64 386
DIST_ARCH := amd64
DIST_OS_DOCKER ?= linux
DIST_ARCH_DOCKER ?= amd64

ROOT_NAME ?= fastEncryptDecode
ROOT_DOCKER_CONTAINER ?= $(ROOT_NAME)
# change this for dockerRun
ROOT_DOCKER_IMAGE_PARENT_NAME ?= golang
ROOT_DOCKER_IMAGE_PARENT_TAG ?= 1.13.3-stretch
# change this for dockerRunLinux or dockerRunDarwin
ROOT_DOCKER_IMAGE_NAME ?= $(ROOT_NAME)
ROOT_DOCKER_IMAGE_TAG ?= $(DIST_VERSION)

ROOT_BUILD_PATH ?= ./build
ROOT_DIST ?= ./dist
ROOT_REPO ?= ./dist
ROOT_LOG_PATH ?= ./log
ROOT_TEST_BUILD_PATH ?= $(ROOT_BUILD_PATH)/test/$(DIST_VERSION)
ROOT_TEST_DIST_PATH ?= $(ROOT_DIST)/test/$(DIST_VERSION)
ROOT_TEST_OS_DIST_PATH ?= $(ROOT_DIST)/$(DIST_OS)/test/$(DIST_VERSION)
ROOT_REPO_DIST_PATH ?= $(ROOT_REPO)/$(DIST_VERSION)
ROOT_REPO_OS_DIST_PATH ?= $(ROOT_REPO)/$(DIST_OS)/release/$(DIST_VERSION)

# change this for ip-v4 get
ROOT_LOCAL_IP_V4_LINUX = $$(ifconfig enp8s0 | grep inet | grep -v inet6 | cut -d ':' -f2 | cut -d ' ' -f1)
ROOT_LOCAL_IP_V4_DARWIN = $$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2)

# can use as https://goproxy.io/ https://gocenter.io https://mirrors.aliyun.com/goproxy/
INFO_GO_PROXY ?= https://goproxy.io/

checkEnvGOPATH:
ifndef GOPATH
	@echo Environment variable GOPATH is not set
	exit 1
endif

init:
	@echo "~> start init this project"
	@echo "-> check version"
	go version
	@echo "-> check env golang"
	go env
	@echo "~> you can use [ make help ] see more task"
	-GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod vendor

checkDepends:
	# in GOPATH just use GO111MODULE=on go mod init to init
	-GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod verify

downloadDepends:
	-GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod download
	-GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod vendor

tidyDepends:
	-GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod tidy

dep: checkDepends downloadDepends
	@echo "just check depends info below"

dependenciesGraph:
	GOPROXY="$(INFO_GO_PROXY)" GO111MODULE=on go mod graph -dot

cleanBuild:
	@if [ -d ${ROOT_BUILD_PATH} ]; then rm -rf ${ROOT_BUILD_PATH} && echo "~> cleaned ${ROOT_BUILD_PATH}"; else echo "~> has cleaned ${ROOT_BUILD_PATH}"; fi

cleanDist:
	@if [ -d ${ROOT_DIST} ]; then rm -rf ${ROOT_DIST} && echo "~> cleaned ${ROOT_DIST}"; else echo "~> has cleaned ${ROOT_DIST}"; fi

cleanLog:
	@if [ -d ${ROOT_LOG_PATH} ]; then rm -rf ${ROOT_LOG_PATH} && echo "~> cleaned ${ROOT_LOG_PATH}"; else echo "~> has cleaned ${ROOT_LOG_PATH}"; fi

clean: cleanBuild cleanLog
	@echo "~> clean finish"

checkTestBuildPath:
	@if [ ! -d ${ROOT_TEST_BUILD_PATH} ]; then mkdir -p ${ROOT_TEST_BUILD_PATH} && echo "~> mkdir ${ROOT_TEST_BUILD_PATH}"; fi

checkTestDistPath:
	@if [ ! -d ${ROOT_TEST_DIST_PATH} ]; then mkdir -p ${ROOT_TEST_DIST_PATH} && echo "~> mkdir ${ROOT_TEST_DIST_PATH}"; fi

checkTestOSDistPath:
	@if [ ! -d ${ROOT_TEST_OS_DIST_PATH} ]; then mkdir -p ${ROOT_TEST_OS_DIST_PATH} && echo "~> mkdir ${ROOT_TEST_OS_DIST_PATH}"; fi

checkReleaseDistPath:
	@if [ ! -d ${ROOT_REPO_DIST_PATH} ]; then mkdir -p ${ROOT_REPO_DIST_PATH} && echo "~> mkdir ${ROOT_REPO_DIST_PATH}"; fi

checkReleaseOSDistPath:
	@if [ ! -d ${ROOT_REPO_OS_DIST_PATH} ]; then mkdir -p ${ROOT_REPO_OS_DIST_PATH} && echo "~> mkdir ${ROOT_REPO_OS_DIST_PATH}"; fi

buildMain:
	@echo "-> start build local OS"
	@go build -o build/main main.go

buildARCH:
	@echo "-> start build OS:$(DIST_OS) ARCH:$(DIST_ARCH)"
	@GOOS=$(DIST_OS) GOARCH=$(DIST_ARCH) go build -o build/main main.go

dev: buildMain
	-ENV_WEB_AUTO_HOST=true ./build/main

run: dev
	@echo "=> run start"

test:
	@echo "=> run test start"
	@go test -test.v

testBenchmem:
	@echo "=> run test benchmem start"
	@go test -test.benchmem

dockerLocalImageInit:
	docker build --tag $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) .

dockerLocalImageRebuild:
	docker image rm $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION)
	docker build --tag $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) .

localIPLinux:
	@echo "=> now run as docker with linux"
	@echo "local ip address is: $(ROOT_LOCAL_IP_V4_LINUX)"

dockerRunLinux: localIPLinux
	@echo "=> check local image as $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)"
	docker image inspect --format='{{ .Created}}' $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	ENV_WEB_HOST=$(ROOT_LOCAL_IP_V4_LINUX) \
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER) \
	ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	ENV_WEB_HOST=$(ROOT_LOCAL_IP_V4_LINUX) \
	DIST_VERSION=$(DIST_VERSION) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER)
	docker logs $(ROOT_DOCKER_CONTAINER) -f

localIPDarwin:
	@echo "=> now run as docker with darwin"
	@echo "local ip address is: $(ROOT_LOCAL_IP_V4_DARWIN)"

dockerRunDarwin: localIPDarwin
	@echo "=> check local image as $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)"
	docker image inspect --format='{{ .Created}}' $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	ENV_WEB_HOST=$(ROOT_LOCAL_IP_V4_LINUX) \
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER) \
	ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	ENV_WEB_HOST=$(ROOT_LOCAL_IP_V4_DARWIN) \
	DIST_VERSION=$(DIST_VERSION) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER)
	docker logs $(ROOT_DOCKER_CONTAINER) -f

dockerRun:
	@echo "=> Now run as docker ENV"
	@echo "-> env ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_PARENT_NAME)"
	@echo "-> env ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_PARENT_TAG)"
	@echo "-> env image: ${ROOT_DOCKER_IMAGE_PARENT_NAME}:${ROOT_DOCKER_IMAGE_PARENT_TAG}"
	@echo "-> env container_name: ROOT_DOCKER_CONTAINER=$(ROOT_NAME)"
	@echo "-> env DIST_VERSION=$(DIST_VERSION)"
	@echo ""
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER) \
	ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_PARENT_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_PARENT_TAG) \
	DIST_VERSION=$(DIST_VERSION) \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_DOCKER_CONTAINER) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_DOCKER_CONTAINER)
	docker logs $(ROOT_DOCKER_CONTAINER) -f

dockerStop:
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER) \
	ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	DIST_VERSION=$(DIST_VERSION) \
	docker-compose stop

dockerPrune: dockerStop
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER) \
	ROOT_DOCKER_IMAGE_NAME=$(ROOT_DOCKER_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ROOT_DOCKER_IMAGE_TAG) \
	DIST_VERSION=$(DIST_VERSION) \
	docker-compose rm -f $(ROOT_DOCKER_CONTAINER)
	docker network prune
	docker volume prune

help:
	@echo "make init - check base env of this project"
	@echo "make dep - check depends of project and download all"
	@echo "make dependenciesGraph - see depends graph of project"
	@echo "make tidyDepends - tidy depends graph of project"
	@echo "make clean - remove binary file and log files"
	@echo ""
	@echo "-- now build name: $(ROOT_NAME) version: $(DIST_VERSION)"
	@echo "-- distTestOS or distReleaseOS will out abi as: $(DIST_OS) $(DIST_ARCH) --"
	@echo ""
	@echo "make test - run test case all benchmem"
	@echo "make testBenchmem - run go test benchmem case all"
	@echo "make dev - run as develop"
	@echo ""
	@echo "make dockerStop - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER)"
	@echo "make dockerPrune - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER) and try to remove"
	@echo ""
	@echo "make dockerRunLinux - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER) in dockerRunLinux"
	@echo "make dockerRunDarwin - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER) in macOS"
	@echo "make dockerRun - run image: $(ROOT_DOCKER_IMAGE_PARENT_NAME):$(ROOT_DOCKER_IMAGE_PARENT_TAG) \
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER)"
