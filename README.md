# flux-promotion-example

This repository features an example for continuously deploying an application using [flux](https://fluxcd.io) and promoting it between different environments/stages.

## Run Example on a Local Cluster

### Basic Setup

Start a [kind](https://kind.sigs.k8s.io) cluster, install flux and connect it to this repository:

```bash
make kind-up
export KUBECONFIG=$PWD/kind-kubeconfig.yaml
make flux-bootstrap
```

### Optional: Read-Write Deploy Key

Testing the upgrade automation requires an ssh deploy key with read-write access.
Create an ssh key secret with flux and add it to the repository:

```
flux create secret git flux-system --url ssh://git@github.com/timebertt/flux-promotion-example
✚ deploy key: ecdsa-sha2-nistp384 AAAA...

► git secret 'flux-system' created in 'flux-system' namespace
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
