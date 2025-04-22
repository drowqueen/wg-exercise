## Prerequisites
Helm, wgc (Wundergraph CLI), kubectl

## How to deploy the Kubernetes apps

### Create a federated graph and graphapi token

```
wgc federated-graph create main —namespace default
wgc router token create maintoken --graph-name main --namespace default
```
Write down the token value for the kubernetes secret setup


### Create the minimal subgraph app
Go to minimal-subgraph folder and run:

```
docker buildx build --platform linux/amd64 -t gcr.io/cosmo-exercise/minimal-subgraph:latest --push .
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```
Retrieve the external ip of the minimal-subgraph service and plug it into the next command:
```
wgc subgraph create \
  --name minimal-subgraph \
  --graph main \
  --routing-url http://<service-ip>:8080 \
  --schema ./graph/schema.graphqls
wgc subgraph publish minimal-subgraph --schema graph/schema.graphqls --namespace default
```

### Deploy the cosmo router
Go to cosmo-router folder and put the base64 encoded token in router-secret.yaml 
Run the following commands:

```
kubectl apply -f router-secret.yaml
helm install router oci://ghcr.io/wundergraph/cosmo/helm-charts/router \
  --version   0.10.0\
  -n default \
  -f values.yaml
kubectl apply -f router-config.yaml
```
Retrieve the external ip of the minimal-subgraph service and plug it into the next command:

wgc federated-graph update main \
  --namespace default \
  --routing-url http://<router-service-ip>/query
```






