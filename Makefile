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
export TAG ?= $(shell ./hack/get-semver-tag.sh)

run:
	APP_VERSION=$(TAG) go run ./app

export GIT_REPO ?= https://github.com/timebertt/flux-promotion-example
export KO_DOCKER_REPO ?= ghcr.io/timebertt/flux-promotion-example
export ARTIFACT_REPO ?= ghcr.io/timebertt/manifests/flux-promotion-example
export PUSH ?= false

build: $(FLUX) $(KO) $(KUSTOMIZE)
	./hack/build.sh

# =============
# Flux
# =============

flux-bootstrap: $(FLUX)
	flux check --pre
	flux install --components-extra="image-reflector-controller,image-automation-controller"
	flux create source git flux-system --url $(GIT_REPO) --branch master --interval 1m
	flux create kustomization flux-system --source flux-system --path ./clusters/kind --prune --interval 10m
