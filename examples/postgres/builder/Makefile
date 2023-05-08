build-manifest:
	rm ./manifest.yaml || "true"
	cd src && ./build-manifest.sh >> ../manifest.yaml

apply-manifest: build-manifest
	cd src && ./apply-manifest.sh ../manifest.yaml || "true"
	rm ./manifest.yaml