# rubectl

This is a Ruby script that generates a scaffold for a Kubernetes operator using the options provided by the user. It generates multiple files that can be used to create and deploy a custom Kubernetes operator.

## Prerequisites

- This script requires [Ruby](https://www.ruby-lang.org/en/downloads/) to be installed on your system.
- You need to install thor into your system 
  
  ```gem install thor```

## Usage

options:

- arg[1] - The name of the scaffold (required)
- arg[2] - The name (plural) from crd (required)
- arg[3] - The ApiVersion from crd (required)
- arg[4] - The api group of the scaffold (required)
- arg[5] - The short name of the crd (required)
- arg[6] - The container registry url that will have the docker image (required)
- arg[7] - The container registry name that will have the docker image (required)
- arg[8] - The repository name (required)
- --sleeptimer=The throughput of requests to K8s cluster (optional)
- --namespace=The namespace of the scaffold (optional)

## Examples

```
thor rubctl operator operators v1 apigroup opr docker.io registry operator --namespace=abc --sleeptimer=123
```

```
thor rubctl operator operators v1 apigroup opr docker.io registry operator --sleeptimer=123
```
## Output

- either namespaced or clustered helm charts to be deployed on your k8s cluster
- github build pipeline
- controller that would be added to your cluster

## Note
- In order to use the GitHub Actions workflow, you need to add REPO_ACCESS_TOKEN to your repo secrets.
- This scaffold deploys your operator controller but it doesn't create an instance from you custom resource