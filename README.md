**NOTICE**
Project Blockhead has been accepted as a Cloud Foundry incubator project and a rewrite of the project has been happening under [cloudfoundry-incubator/blockhead](https://github.com/cloudfoundry-incubator/blockhead).

This repository will be deprecated soon and in favor of the new work that is happening.

# BOSH release for ethereum-containers-broker

## Introduction

Project BlockHead takes advantage of the Open Service Broker API specification to build a service broker layer placed between the Web application and the blockchain network. 
Doing so, the broker controls management of the smart contract by automating creation and deployment of smart contracts and then exposing the required set of information to the Web application.

The first version of the broker is built on top of the [Container Service Broker](https://github.com/cloudfoundry-community/cf-containers-broker), a Cloud Foundry community project. By utilizing the container service broker, blockchain nodes can be run inside an isolated Docker container and operate independently when deploying and binding smart contracts.

We utilize the broker to deploy stateful Ethereum nodes on demand. Each step in provisioning and binding or unbinding and deprovisioning are then modified to deliver on creation / deletion of smart contracts or nodes. Picture below provides an overall architecture for how the Blockhead service broker provisions Ethereum nodes and integrates with the Cloud Foundry applications:o

![Broker Architecture](https://cdn-images-1.medium.com/max/2000/1*AovE-c2jJyQ_czkQqUFqAQ.png)

For details on the broker, read our blog post on Hacker Noon, [HERE](https://hackernoon.com/project-blockhead-an-ethereum-smart-contract-service-broker-for-kubernetes-and-cloud-foundry-88390a3ac63f).

## Deploy the Broker

Current version of the broker requires deployment alongside Cloud Foundry. For instructions on how to deploy Cloud Foundry refer to the [deployment docs](https://docs.cloudfoundry.org/deploying/index.html).

With a running Cloud Foundry deployment, run the `deploy.sh` script embedded in this repository. 
However, prior to doing so you need to modify `manifests/local-release.yml` to point to the location where you have cloned this repo on your workstation.

Also you may wish to change `--vers-file` to `--vars-store` in the `deploy.sh` script for it to generate new credentials first time around, when you run the script.


## Update the Ethereum Service

In order to update / alter the service Ethereum node service offered by the broker, you need to modify `manifests/operators/services/geth.yml` shown below:

```
---
- type: replace
  path: /instance_groups/name=docker/jobs/name=cf-containers-broker/properties/services/-
  value:
    name: 'eth'
    id: '24736f4a-72b8-4298-96f7-b48c4045ddfd'
    description: 'Ethereum Geth Node'
    bindable: true
    tags:
      - 'eth'
      - 'geth'
    metadata:
      displayName: 'Geth 1.8'
      longDescription: 'Geth Node'
      providerDisplayName: 'Cloud Foundry Community'
    dashboard_client:
      id: docker-broker-eth
      secret: ((docker-broker-eth-secret))
    plans:
    - id: 'd42fc3cc-1341-4aa3-866e-01bc5243dc2e'
      name: 'free'
      container:
        backend: 'docker'
        image: 'nimak/eth-dev'
      description: 'Free Trial'
      metadata:
        costs:
          - amount:
              usd: 0.0
            unit: 'MONTHLY'
        bullets:
          - 'Dedicated Geth Node'

- type: replace
  path: /variables/-
  value:
    name: docker-broker-eth-secret
    type: password
```
