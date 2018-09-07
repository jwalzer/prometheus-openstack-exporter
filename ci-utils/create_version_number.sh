#!/bin/sh -x
# create version number schema
#

# dooing some initial stuff first - find out where we are ...
pwd
ls
#git remote add -f --tags upstream $CI_REPOSITORY_URL
#git fetch $CI_REPOSITORY_URL
git status
git branch

UPSTREAM_MASTER_COMMIT="$(git merge-base --octopus master)"
UPSTREAM_MASTER_ID="$(git describe --tags $UPSTREAM_MASTER_COMMIT| grep -o '[^/]*$' || true)"
[ -z "$UPSTREAM_MASTER_ID" ] && UPSTREAM_MASTER_ID="$(git describe --all $UPSTREAM_MASTER_COMMIT| grep -o '[^/]*$')"
LOCAL_VERSION="$(git describe --all HEAD | grep -o '[^/]*$')"
BUILDDATE="$(date +%Y%m%d)"
export IMAGE_TAG="$CI_REGISTRY_IMAGE/${UPSTREAM_MASTER_ID}/${LOCAL_VERSION}-${BUILDDATE}-${CI_PIPELINE_IID}"