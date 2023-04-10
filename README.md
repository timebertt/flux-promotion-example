# flux-promotion-example

## Run Example on a Local Cluster

Start a [kind](https://kind.sigs.k8s.io) cluster, install flux and connect it to this repository:

```bash
make kind-up
export KUBECONFIG=$PWD/kind-kubeconfig.yaml
make flux-bootstrap
```
