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

push-manifest: build-manifest
	cd src && ./push-manifest.sh ../manifest.yaml || "true"
	rm ./manifest.yaml