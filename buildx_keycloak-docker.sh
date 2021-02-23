#!/bin/bash

# can pass as args (`buildx_keycloak-docker.sh "20.0.1" "server"` or use defaults here)
KEYCLOAK_VERSION=${1:-"12.0.3"}
SERVER=${2:-"server"}
# SERVER=${2:-"server-x"}

REGISTRY="ahgraber"
TAG=${3:-"latest"}

# clone/update keycloak container instructions
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# pull KEYCLOAK_VERSION files
mkdir -p ./src
curl -L -o "./src/keycloak-${KEYCLOAK_VERSION}.tar.gz" "https://github.com/keycloak/keycloak-containers/archive/${KEYCLOAK_VERSION}.tar.gz" \
    && tar -xzf "./src/keycloak-${KEYCLOAK_VERSION}.tar.gz" -C ./src \
	&& rm "./src/keycloak-${KEYCLOAK_VERSION}.tar.gz"

cd ./src/keycloak-containers-${KEYCLOAK_VERSION}/${SERVER}

# update ./tools/docker-entrypont.sh's `file_env()`` to use __FILE ("dunder FILE")
if [ SERVER='server' ]; then
	sed -i.bak 's|local fileVar=[\"]$[\{]var[\}]_FILE[\"]|local fileVar=\"$\{var\}__FILE\"|' ./tools/docker-entrypoint.sh
else
	sed -i.bak 's|local CONFIG_MARKER_FILE=[\"]$[\{]var[\}]_FILE[\"]|local CONFIG_MARKER_FILE=\"$\{var\}__FILE\"|' ./tools/docker-entrypoint.sh
fi

# buildx
docker buildx create --name "${BUILDX_NAME:-keycloak}" || echo
docker buildx use "${BUILDX_NAME:-keycloak}"

docker buildx build \
	-f Dockerfile \
    -t ${REGISTRY}/keycloak:${KEYCLOAK_VERSION} \
	--platform linux/amd64,linux/arm64 \
	--push \
	.

# cleanup
docker buildx rm "${BUILDX_NAME:-keycloak}"
cd ${DIR} \
	&& rm -rf ./src