#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/.."
cd "$repo_root"

# prepare metadata
revision=$(git branch --show-current)@sha1:$(git rev-parse HEAD)
# if there is a tag pointing at HEAD, use it
head_tag="$(git tag --points-at HEAD)"
if [ -n "$head_tag" ]; then
  revision="$head_tag"
fi

# build image and save full reference including digest
image_ref_app="$(ko build \
  --sbom none --base-import-paths --platform linux/amd64,linux/arm64 \
  --image-label org.opencontainers.image.source="$GIT_REPO" \
  -t "$TAG" --push="$PUSH" \
  "$repo_root"/app | tee /dev/stderr)"

# prepare artifact build in a temporary directory
tmp=$(mktemp -d)
echo "$tmp"
cd "$tmp"
cp -r "$repo_root"/app/manifests .

# inject freshly-built image reference into the manifests
pushd manifests >/dev/null
kustomize edit set image hello="$image_ref_app"
popd >/dev/null

# push artifacts to registry
if ! $PUSH; then
  echo "skip pushing manifest artifacts in dry-run mode"
  exit 0
fi

flux push artifact oci://"$ARTIFACT_REPO"/app:"$TAG" \
  --path=./manifests \
  --source="$GIT_REPO" \
  --revision="$revision"
