#!/bin/bash

# This script runs a docker build for the service in the current directory.
# Pulling in its dependencies as defined by monobuild.
#
# Note that it requires gnu-tar on macos which can be installed via brew.

set -euo pipefail
IFS=$'\n\t'

if [[ ! -e "Dockerfile" ]]; then
	echo "You need to run this command in a folder with a Dockerfile"
	exit 1
fi

REGISTRY_URL=${REGISTRY_URL}

echo "Using registry $REGISTRY_URL"

SERVICE_PATH=$(git rev-parse --show-prefix)
SERVICE_PATH=${SERVICE_PATH%/}

SERVICE_NAME=$(basename $(pwd))
GIT_HASH=$(git rev-parse --short HEAD)

DOCKER_IMAGE=$REGISTRY_URL/$SERVICE_NAME
DOCKER_TAG=$GIT_HASH
DOCKER_URL=$DOCKER_IMAGE:$DOCKER_TAG

DEPENDENCIES=$(cd ../.. && go run github.com/charypar/monobuild@latest print --scope $SERVICE_PATH | cut -d: -f 1)

# We specifically need gnu-tar as it has the --exclude-vcs-ignores
# option.  On linux that's generally tar, on macos it's gtar (and
# can be installed via brew)
if [ "$(uname)" == "Darwin" ]; then
	TAR=gtar
else
	TAR=tar
fi

# JS builds need some top-level files.  Since they're not very big
# we include them in all builds.
JS_FILES=(package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json .prettierrc.json)

ADDITIONAL_DOCKER_ARGS=()

CI="${CI:-false}"
SHOULD_CACHE="${SHOULD_CACHE:-$CI}"
if [[ "${SHOULD_CACHE}" = "true" ]]; then
    # See https://github.com/moby/buildkit/tree/master#github-actions-cache-experimental
	ADDITIONAL_DOCKER_ARGS=(--cache-from type=gha,scope=$SERVICE_NAME --cache-to type=gha,scope=$SERVICE_NAME)
fi

REPO_ROOT=$(git rev-parse --show-toplevel)

SHOULD_PUSH="${DOCKER_BUILD_SHOULD_PUSH:-$CI}"

function image_exists() {
    # pull image
    docker pull $1 >/dev/null 2>&1
    # save exit code
    exit_code=$?
    if [ $exit_code = 0 ]; then
        # remove pulled image
        docker rmi $1 >/dev/null 2>&1
        return true
    else
        return false
    fi
}

if [[ "$SHOULD_PUSH" = "true" ]]; then
	ADDITIONAL_DOCKER_ARGS+=(--push)

	if image_exists(); then
		echo "$DOCKER_URL already exists in the docker registry.  Skipping the build"
		exit 0
	fi
fi

echo "Building $SERVICE_NAME"
echo "Dependencies $DEPENDENCIES"

$TAR -c --exclude-vcs-ignores -C $REPO_ROOT "${JS_FILES[@]}" $DEPENDENCIES |
	docker buildx build - -t $DOCKER_URL -f $SERVICE_PATH/Dockerfile ${ADDITIONAL_DOCKER_ARGS[@]+"${ADDITIONAL_DOCKER_ARGS[@]}"}