#!/usr/bin/env bash

ORG=${DOCKER_BUILD_ORG:-damienkastner}

# directory name is
IMAGE=${DOCKER_BUILD_IMAGE:-$(basename "$(pwd)")}
# IMAGE=${DOCKER_BUILD_IMAGE:-chip-build-crosscompile-armhf}

# version
VERSION=${DOCKER_BUILD_VERSION:-$(sed 's/ .*//' version)}

if [[ $OSTYPE == 'darwin'* ]]; then
    DOCKER_VOLUME_PATH=~/Library/Containers/com.docker.docker/Data/vms/0/
else
    DOCKER_VOLUME_PATH=/var/lib/docker/
fi

[[ ${*/--help//} != "${*}" ]] && {
    set +x
    echo "Usage: <OPTIONS>

  Build and (optionally tag as latest, push) a docker image from Dockerfile in CWD

  Options:
   --no-cache   passed as a docker build argument
   --latest     update latest to the current built version (\"$VERSION\")
   --push       push image(s) to docker.io (requires docker login for \"$ORG\")
   --skip-build skip the build/prune step
   --help       get this message
   --squash     squash docker layers before push them to docker.io (requires docker-squash python module)

"
    exit 0
}

die() {
    echo "*** ERROR: $*"
    exit 1
}

set -ex

[[ -n $VERSION ]] || die "version cannot be empty"

if [ -f "$DOCKER_VOLUME_PATH" ]; then
    mb_space_before=$(df -m "$DOCKER_VOLUME_PATH" | awk 'FNR==2{print $3}')
fi

BUILD_ARGS=()
if [[ ${*/--no-cache//} != "${*}" ]]; then
    BUILD_ARGS+=(--no-cache)
fi

[[ ${*/--skip-build//} != "${*}" ]] || {
    docker build "${BUILD_ARGS[@]}" --build-arg VERSION="$VERSION" -t "$ORG/$IMAGE:$VERSION" .
    docker image prune --force
}

[[ ${*/--latest//} != "${*}" ]] && {
    docker tag "$ORG"/"$IMAGE":"$VERSION" "$ORG"/"$IMAGE":latest
}

[[ ${*/--squash//} != "${*}" ]] && {
    command -v docker-squash >/dev/null &&
        docker-squash "$ORG"/"$IMAGE":"$VERSION" -t "$ORG"/"$IMAGE":latest
}

[[ ${*/--push//} != "${*}" ]] && {
    docker push "$ORG"/"$IMAGE":"$VERSION"
    [[ ${*/--latest//} != "${*}" ]] && {
        docker push "$ORG"/"$IMAGE":latest
    }
}

docker images --filter=reference="$ORG/*"
if [ -f "$DOCKER_VOLUME_PATH" ]; then
    df -h "$DOCKER_VOLUME_PATH"
    mb_space_after=$(df -m "$DOCKER_VOLUME_PATH" | awk 'FNR==2{print $3}')
    printf "%'.f MB total used\n" "$((mb_space_before - mb_space_after))"
fi

exit 0
