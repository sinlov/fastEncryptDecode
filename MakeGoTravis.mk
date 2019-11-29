# this file must use as base Makefile

travisTest:
	GO111MODULE=on go test -v *.go

travisConvey:
	GO111MODULE=on go test -cover -coverprofile=coverage.txt -covermode=atomic -v *.go

travisConveyLocal:
	@echo "-> use goconvey at https://github.com/smartystreets/goconvey"
	@echo "-> see report at http://localhost:8080"
	which goconvey
	goconvey -depth=1 -launchBrowser=false -workDir=$$PWD

helpGoTravis:
	@echo "Help: MakeTravis.mk"
	@echo "~> make travisTest - run project test"
	@echo "~> make travisConvey - run project convery"
	@echo "~> make travisConveyLocal - run project convery local as tools https://github.com/smartystreets/goconvey"
	@echo ""