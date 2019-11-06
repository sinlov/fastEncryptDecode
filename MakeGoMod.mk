# this file must use as base Makefile

modVerify:
	# in GOPATH must use GO111MODULE=on go mod init to init
	-GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod verify

modDownload:
	-GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod download
	-GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod vendor

modTidy:
	-GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod tidy

dep: modVerify modDownload
	@echo "just check depends info below"

modGraphDependencies:
	GOPROXY="$(ENV_GO_PROXY)" GO111MODULE=on go mod graph

helpGoMod:
	@echo "Help: MakeGoMod.mk"
	@echo "this project use go mod, so golang version must 1.12+"
	@echo "go mod evn: GOPROXY=$(ENV_GO_PROXY)"
	@echo "~> make dep - check depends of project and download all, child task is: modVerify modDownload"
	@echo "~> make modGraphDependencies - see depends graph of this project"
	@echo "~> make modTidy - tidy depends graph of project"
	@echo ""