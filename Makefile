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
ROOT_DOCKER_SERVICE ?= $(ROOT_NAME)
ROOT_BUILD_PATH ?= ./build
ROOT_DIST ?= ./dist
ROOT_REPO ?= ./dist
ROOT_TEST_BUILD_PATH ?= $(ROOT_BUILD_PATH)/test/$(DIST_VERSION)
ROOT_TEST_DIST_PATH ?= $(ROOT_DIST)/test/$(DIST_VERSION)
ROOT_TEST_OS_DIST_PATH ?= $(ROOT_DIST)/$(DIST_OS)/test/$(DIST_VERSION)
ROOT_REPO_DIST_PATH ?= $(ROOT_REPO)/$(DIST_VERSION)
ROOT_REPO_OS_DIST_PATH ?= $(ROOT_REPO)/$(DIST_OS)/release/$(DIST_VERSION)

ROOT_LOG_PATH ?= ./log
ROOT_SWAGGER_PATH ?= ./docs

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

dep: checkDepends
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

buildDocker: checkDepends cleanBuild
	@echo "-> start build OS:$(DIST_OS_DOCKER) ARCH:$(DIST_ARCH_DOCKER)"
	@GOOS=$(DIST_OS_DOCKER) GOARCH=$(DIST_ARCH_DOCKER) go build -o build/main main.go

dev: buildMain
	-ENV_WEB_AUTO_HOST=true ./build/main -c ./conf/config.yaml

runTest:  buildMain
	-ENV_WEB_AUTO_HOST=true ./build/main -c ./conf/test/config.yaml

test: checkDepends buildMain checkTestDistPath
	mv ./build/main $(ROOT_TEST_DIST_PATH)
	@echo "=> pkg at: $(ROOT_TEST_DIST_PATH)"

testTar: test
	cd $(ROOT_DIST)/test && tar zcvf $(ROOT_NAME)-test-$(DIST_VERSION).tar.gz $(DIST_VERSION)

testOS: checkDepends buildARCH checkTestOSDistPath
	@echo "=> Test at: $(DIST_OS) ARCH as: $(DIST_ARCH)"
	mv ./build/main $(ROOT_TEST_OS_DIST_PATH)
	@echo "=> pkg at: $(ROOT_TEST_OS_DIST_PATH)"

testOSTar: testOS
	@echo "=> start tar test as os $(DIST_OS) $(DIST_ARCH)"
	tar zcvf $(ROOT_DIST)/$(DIST_OS)/test/$(ROOT_NAME)-$(DIST_OS)-$(DIST_ARCH)-$(DIST_VERSION).tar.gz $(ROOT_TEST_OS_DIST_PATH)

release: checkDepends buildMain checkReleaseDistPath
	mv ./build/main $(ROOT_REPO_DIST_PATH)
	@echo "=> pkg at: $(ROOT_REPO_DIST_PATH)"

releaseOS: checkDepends buildARCH checkReleaseOSDistPath
	@echo "=> Release at: $(DIST_OS) ARCH as: $(DIST_ARCH)"
	mv ./build/main $(ROOT_REPO_OS_DIST_PATH)
	@echo "=> pkg at: $(ROOT_REPO_OS_DIST_PATH)"

releaseOSTar: releaseOS
	@echo "=> start tar release as os $(DIST_OS) $(DIST_ARCH)"
	tar zcvf $(ROOT_DIST)/$(DIST_OS)/release/$(ROOT_NAME)-$(DIST_OS)-$(DIST_ARCH)-$(DIST_VERSION).tar.gz $(ROOT_REPO_OS_DIST_PATH)

# just use test config and build as linux amd64
dockerRun: buildDocker checkTestBuildPath
	mv ./build/main $(ROOT_TEST_BUILD_PATH)
	@echo "=> pkg at: $(ROOT_TEST_BUILD_PATH)"
	@echo "-> try run docker container $(ROOT_NAME)"
	ROOT_NAME=$(ROOT_NAME) DIST_VERSION=$(DIST_VERSION) docker-compose up -d
	-sleep 5
	@echo "=> container $(ROOT_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(ROOT_NAME)

dockerStop:
	ROOT_NAME=$(ROOT_NAME) DIST_VERSION=$(DIST_VERSION) docker-compose stop

dockerRemove: dockerStop
	ROOT_NAME=$(ROOT_NAME) DIST_VERSION=$(DIST_VERSION) docker-compose rm -f $(ROOT_DOCKER_SERVICE)
	docker network prune

help:
	@echo "make init - check base env of this project"
	@echo "make dep - check depends of project"
	@echo "make dependenciesGraph - see depends graph of project"
	@echo "make tidyDepends - tidy depends graph of project"
	@echo "make clean - remove binary file and log files"
	@echo ""
	@echo "-- now build name: $(ROOT_NAME) version: $(DIST_VERSION)"
	@echo "-- testOS or releaseOS will out abi as: $(DIST_OS) $(DIST_ARCH) --"
	@echo "make test - build dist at $(ROOT_TEST_DIST_PATH)"
	@echo "make testOS - build dist at $(ROOT_TEST_OS_DIST_PATH)"
	@echo "make testOSTar - build dist at $(ROOT_TEST_OS_DIST_PATH) and tar"
	@echo "make release - build dist at $(ROOT_REPO_DIST_PATH)"
	@echo "make releaseOS - build dist at $(ROOT_REPO_OS_DIST_PATH)"
	@echo "make releaseOSTar - build dist at $(ROOT_REPO_OS_DIST_PATH) and tar"
	@echo ""
	@echo "make runTest - run server use conf/test/config.yaml"
	@echo "make dev - run server use conf/config.yaml"
	@echo "make dockerRun - run docker-compose server as $(ROOT_DOCKER_SERVICE) container-name at $(ROOT_NAME)"
	@echo "make dockerStop - stop docker-compose server as $(ROOT_DOCKER_SERVICE) container-name at $(ROOT_NAME)"
