REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# =============
# Tools
# =============

TOOLS_DIR := hack/tools
include hack/tools.mk

# =============
# Local cluster
# =============

kind-up: $(KIND)
	kind create cluster --name flux --kubeconfig kind-kubeconfig.yaml

kind-down: $(KIND)
	kind delete cluster --name flux

# =============
# APP
# =============

export GIT_REPO ?= https://github.com/timebertt/flux-promotion-example
export KO_DOCKER_REPO ?= ghcr.io/timebertt/flux-promotion-example
export ARTIFACT_REPO ?= ghcr.io/timebertt/manifests/flux-promotion-example

run:
	APP_ENV=local go run ./app

export TAG ?= $(shell ./hack/get-semver-tag.sh)
export PUSH ?= false

build: $(KO) $(KUSTOMIZE)
	./hack/build.sh
