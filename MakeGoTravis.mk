# this file must use as base Makefile

travisInstall:
	GOPROXY=$(ENV_GO_PROXY) GO111MODULE=on go get -t -v ./...

travisTest:
	GO111MODULE=on go test -v ./... -timeout 1m

travisTestFail:
	GO111MODULE=on go test -v ./... -timeout 1m | grep FAIL --color

travisConvey:
	GO111MODULE=on go test -cover -coverprofile=coverage.txt -covermode=atomic -v ./...

travisConveyLocal:
	@echo "-> use goconvey at https://github.com/smartystreets/goconvey"
	@echo "-> see report at http://localhost:8080"
	which goconvey
	goconvey -depth=1 -launchBrowser=false -workDir=$$PWD

helpGoTravis:
	@echo "Help: MakeTravis.mk"
	@echo "~> make travisInstall     - run project to test travis"
	@echo "~> make travisTest        - run project test"
	@echo "~> make travisTestFail    - run project test fast find FAIL"
	@echo "~> make travisConvey      - run project convery"
	@echo "~> make travisConveyLocal - run project convery local as tools https://github.com/smartystreets/goconvey"
	@echo ""