# This make file is supposed to be included in the top-level make file.
# It can be reused by repos vendoring g/g to have some common make recipes for building and installing development
# tools as needed.
# Recipes in the top-level make file should declare dependencies on the respective tool recipes (e.g. $(CONTROLLER_GEN))
# as needed. If the required tool (version) is not built/installed yet, make will make sure to build/install it.
# The *_VERSION variables in this file contain the "default" values, but can be overwritten in the top level make file.

TOOLS_BIN_DIR              := $(TOOLS_DIR)/bin
FLUX                       := $(TOOLS_BIN_DIR)/flux
KIND                       := $(TOOLS_BIN_DIR)/kind
KO                         := $(TOOLS_BIN_DIR)/ko
KUSTOMIZE                  := $(TOOLS_BIN_DIR)/kustomize

# default tool versions
FLUX_VERSION ?= v2.0.0-rc.1
KIND_VERSION ?= v0.18.0
KO_VERSION ?= v0.13.0
KUSTOMIZE_VERSION ?= v5.0.1

export TOOLS_BIN_DIR := $(TOOLS_BIN_DIR)
export PATH := $(abspath $(TOOLS_BIN_DIR)):$(PATH)

#########################################
# Common                                #
#########################################

# Tool targets should declare go.mod as a prerequisite, if the tool's version is managed via go modules. This causes
# make to rebuild the tool in the desired version, when go.mod is changed.
# For tools where the version is not managed via go.mod, we use a file per tool and version as an indicator for make
# whether we need to install the tool or a different version of the tool (make doesn't rerun the rule if the rule is
# changed).

# Use this "function" to add the version file as a prerequisite for the tool target: e.g.
#   $(HELM): $(call tool_version_file,$(HELM),$(HELM_VERSION))
tool_version_file = $(TOOLS_BIN_DIR)/.version_$(subst $(TOOLS_BIN_DIR)/,,$(1))_$(2)

# This target cleans up any previous version files for the given tool and creates the given version file.
# This way, we can generically determine, which version was installed without calling each and every binary explicitly.
$(TOOLS_BIN_DIR)/.version_%:
	@version_file=$@; rm -f $${version_file%_*}*
	@touch $@

.PHONY: clean-tools-bin
clean-tools-bin:
	rm -rf $(TOOLS_BIN_DIR)/*

#########################################
# Tools                                 #
#########################################

$(FLUX): $(call tool_version_file,$(FLUX),$(FLUX_VERSION))
	curl -L -o - https://github.com/fluxcd/flux2/releases/download/$(FLUX_VERSION)/flux_$(subst v,,$(FLUX_VERSION))_$(shell uname -s | tr '[:upper:]' '[:lower:]')_$(shell uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/').tar.gz | tar -xzmvf - -C $(TOOLS_BIN_DIR) flux

$(KIND): $(call tool_version_file,$(KIND),$(KIND_VERSION))
	curl -L -o $(KIND) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-$(shell uname -s | tr '[:upper:]' '[:lower:]')-$(shell uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
	chmod +x $(KIND)

$(KO): $(call tool_version_file,$(KO),$(KO_VERSION))
	GOBIN=$(abspath $(TOOLS_BIN_DIR)) go install github.com/google/ko@$(KO_VERSION)

$(KUSTOMIZE): $(call tool_version_file,$(KUSTOMIZE),$(KUSTOMIZE_VERSION))
	GOBIN=$(abspath $(TOOLS_BIN_DIR)) go install sigs.k8s.io/kustomize/kustomize/v5@$(KUSTOMIZE_VERSION)
