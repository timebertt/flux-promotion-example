# flux-promotion-example

This repository features an example for continuously deploying an application using [flux](https://fluxcd.io) and promoting it between different environments/stages.

## Run Example on a Local Cluster

Start a [kind](https://kind.sigs.k8s.io) cluster, install flux and connect it to this repository:

```bash
make kind-up
export KUBECONFIG=$PWD/kind-kubeconfig.yaml
make flux-bootstrap
```

## Repository Structure

```
.
├── app
│  ├── main.go         # app source code
│  └── manifests       # app deployment manifests
├── clusters
│  └── kind            # flux bootstrap config
├── deploy             # OCIRepository+Kustomization per environment
│  ├── base
│  ├── dev             # flux config for app in `dev` environment
│  ├── prod            # flux config for app in `prod` environment
│  └── test            # flux config for app in `test` environment
├── hack               # build scripts and tool binaries
```
