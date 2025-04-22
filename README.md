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

GKE options like enable_autopilot, network, subnetwork, ip_allocation_policy, and private_cluster_config are immutable after creation. 

# Future plans for the GKE cluster

* Google Cloud Monitoring needs to be configured
* Secrets manager configuration needs to be added
* master_authorized_networks_config to be added to allow vpn and/or bastion access
* Enable private nodes and private endpoint for tightened security
* Disable public endpoint for tighter security  a bastion host will be needed.
* Add Cloud NAT for egreess

I am unable to configure an ideal high-security gke cluster due to quota restraints and using free tier.
Resource constraints are added to prometheus and cosmo router to get around the free tier quota restrictions.

## How to deploy the apps

See README under kubernetes folder.

