# rubectl

This is a Ruby script that generates a scaffold for a Kubernetes operator using the options provided by the user. It generates multiple files that can be used to create and deploy a custom Kubernetes operator.

## Prerequisites

This script requires [Ruby](https://www.ruby-lang.org/en/downloads/) to be installed on your system.


## Usage

Run the `scaffold.rb` script with the following options:

- -n, --name NAME: The name of the scaffold (required)
- -p, --plural NAMES: The name (plural) from crd (required)
- -v, --version VERSION: The ApiVersion from crd (required)
- -g, --apigroup APIGROUP: The API group of the scaffold (required)
- -s, --sleeptimer SLEEPTIMER: The throughput of requests to K8s cluster (optional)
- -h, --help: Prints the help text

## Output

- either namespaced or clustered helm charts to be deployed on your k8s cluster
- github build pipeline
- controller that would be added to your cluster

## Note
- In order to use the GitHub Actions workflow, you need to add REPO_ACCESS_TOKEN to your repo secrets.
- This scaffold deploys your operator controller but it doesn't create an instance from you custom resource