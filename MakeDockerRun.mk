# this file must use as base Makefile

# use Makefile ROOT_NAME
ROOT_DOCKER_CONTAINER ?= $(ROOT_NAME)
# change this for dockerRun
ROOT_DOCKER_IMAGE_PARENT_NAME ?= golang
ROOT_DOCKER_IMAGE_PARENT_TAG ?= 1.13.3-stretch
# change this for dockerRunLinux or dockerRunDarwin
ROOT_DOCKER_IMAGE_NAME ?= $(ROOT_NAME)
# can change as local set or read Makefile DIST_VERSION
ROOT_DOCKER_IMAGE_TAG ?= $(DIST_VERSION)

# For Docker dev images init
initDockerDevImages:
	@echo "~> start init this project in docker"
	@echo "-> check version"
	go version
	@echo "-> check env golang"
	go env
	@echo "~> you can use [ make help ] see more task"
	-GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod vendor

dockerLocalImageInit:
	docker build --tag $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) .

dockerLocalImageRebuild:
	docker image rm $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION)
	docker build --tag $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) .

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
	-docker rmi -f $(ROOT_DOCKER_IMAGE_NAME):$(ROOT_DOCKER_IMAGE_TAG)
	docker network prune
	docker volume prune

helpDockerRun:
	@echo "Help: MakeDockerRun.mk"
	@echo "~> make dockerStop      - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER)"
	@echo "~> make dockerPrune     - stop docker-compose container-name at $(ROOT_DOCKER_CONTAINER) and try to remove"
	@echo "Before run this project in docker must use"
	@echo "~> make dockerLocalImageInit to init Docker image"
	@echo "or use"
	@echo "~> make dockerLocalImageRebuild to rebuild Docker image"
	@echo "After build Docker image success"
	@echo "~> make dockerRunLinux  - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER) in dockerRunLinux"
	@echo "~> make dockerRunDarwin - run docker-compose server as $(ROOT_DOCKER_IMAGE_NAME):$(DIST_VERSION) \
	container-name at $(ROOT_DOCKER_CONTAINER) in macOS"
	@echo "~> make dockerRun       - run image: $(ROOT_DOCKER_IMAGE_PARENT_NAME):$(ROOT_DOCKER_IMAGE_PARENT_TAG) \
	ROOT_DOCKER_CONTAINER=$(ROOT_DOCKER_CONTAINER)"
	@echo ""