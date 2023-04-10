#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# if there is a tag pointing at HEAD, use it
head_tag="$(git tag --points-at HEAD)"
if [ -n "$head_tag" ]; then
  echo "$head_tag"
  exit 0
fi

main_branch=master
if command git show-ref -q --verify refs/heads/main >/dev/null; then
  main_branch=main
fi

if last_version="$(git describe --tags --abbrev=0 2>/dev/null)"; then
  last_version_ref="$last_version_ref"
else
  # there is no tag yet
  last_version=v0.0.0
  # use the initial commit as reference point
  last_version_ref="$(git rev-list --max-parents=0 HEAD)"
fi

current_branch="$(git branch --show-current)"

# determine the next releases tag
patch=$(echo "$last_version" | cut -d. -f3)
minor=$(echo "$last_version" | cut -d. -f2)
if [[ "$current_branch" == release-* ]]; then
  # if we're on a release branch, the next version will be a patch release
  next_version="${last_version%.*}.$((patch + 1))"
else
  # otherwise, the next version will be a minor release
  next_version=${last_version%%.*}.$((minor + 1)).$patch
fi

number="$(git rev-list "$last_version_ref"..HEAD --count)"
prerelease="dev.$number.$(date +%s)"
build="$(git rev-parse --short @)"

if ! [ "$current_branch" = $main_branch ]; then
  build="$build.$(echo "$current_branch" | tr '/' '-')"

  # if we're on a development branch, the last pushed images and artifacts should automatically be rolled out
  # (more prerelease identifiers have higher precedence) but should take lower precedence than a new commit on the main
  # branch
  merge_base="$(git merge-base $main_branch HEAD)"
  number="$(git rev-list "$last_version_ref".."$merge_base" --count)"
  prerelease="dev.$number.$(date +%s)"
fi

# Unfortunately, image tags can't contain the + character, which means we can't use the build meta from the semver spec
# (https://semver.org/#spec-item-10). Hence, we append the build meta as another prerelease identifier
echo "$next_version-$prerelease.$build"
