#!/bin/bash

# Run with `sudo bash ./scripts/buildx.sh {VERSION} --tag {REGISTRY}/{IMAGE}:{TAG}`
# `buildx_keycloak-docker.sh 12.0.3 --tag ahgraber/keycloak:latest --tag ahgraber/keycloak:12.0.3
KEYCLOAK_VERSION=$1
SERVER="server"
REGISTRY="ahgraber"
TAG=${@:2}

# check version provided
[[ ${KEYCLOAK_VERSION} = --tag* ]] && \
	echo "ERROR: Did you forget to include the version number?" && \
	echo "Call with 'buildx.sh {VERSION} --tag {REGISTRY}/{IMAGE}:{TAG}'" && \
	exit 1

echo "Building for version ${KEYCLOAK_VERSON}"
echo "Tagging with ${TAG}"

cd ./src/keycloak-containers-${KEYCLOAK_VERSION}/${SERVER}

# buildx
docker buildx create --name "${BUILDX_NAME:-keycloak}" || echo
docker buildx use "${BUILDX_NAME:-keycloak}"

docker buildx build \
	--no-cache \
	--platform linux/amd64,linux/arm64 \
	--file Dockerfile \
	--push \
	${TAG} \
	.

# cleanup
docker buildx rm "${BUILDX_NAME:-keycloak}"
cd ${DIR} \
	&& rm -rf ./src