TAG = $(shell git describe --tags --abbrev=0)
IMAGE_VERSION = $(shell echo ${TAG} | cut -c2-)

.PHONY: build
build-prod:
	sh hack/build.sh prod

.PHONY: build
build-mvm:
	sh hack/build-mvm.sh prod

.PHONY: docker
docker:
	docker build -t dirtoracle:${IMAGE_VERSION} -t dirtoracle:latest -f ./docker/Dockerfile .

.PHONY: docker
docker-mvm:
	docker build -t doracle-mvm:${IMAGE_VERSION} -t doracle-mvm:latest -f ./docker/Dockerfile.mvm .

clean:
	@rm -rf ./builds
