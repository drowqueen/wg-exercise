This project contains terragrunt modules and definitions to create a VPC, a GKE autopilot cluster, Wundergraph Cosmo router and a minimal golang subgraph app to run on the gke cluster.

## How to launch the infrastructure

VPC needs to be deployed first, then the GKE cluster.

cd to the resource subfolder in live/cosmo-exercise and run the following: 

```
terragrunt init
terragrunt validate
terragrunt plan
terragrunt apply
```


