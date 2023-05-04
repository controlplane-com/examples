TAG ?= latest
IMAGE ?= postgres-agent
REPOSITORY ?= kylecupp

build-image:
	docker build -t ${REPOSITORY}/${IMAGE}:${TAG} .

push-image: build-image
	docker push ${REPOSITORY}/${IMAGE}:${TAG}

build-manifest:
	rm ./manifest.yaml || "true"
	cd src && ./build-manifest.sh >> ../manifest.yaml

apply-manifest: build-manifest
	cd src && ./apply-manifest.sh ../manifest.yaml || "true"
	rm ./manifest.yaml