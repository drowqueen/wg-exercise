This minimal subgraph is deployed to gke with service and deployment manifests and linked to the cosmo-router running on gke cluster as a service.

Golang app is created following this tutorial: https://gqlgen.com/getting-started/
 

Example graphql query to run: 

```
query {
  todos {
    id
    text
    done
    user {
      id
      name
    }
  }
}
```