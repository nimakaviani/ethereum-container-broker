# BOSH release for cf-containers-broker

This BOSH release and deployment manifest deploy a cluster of cf-containers-broker.

## Usage

This repository includes base manifests and operator files. They can be used for initial deployments and subsequently used for updating your deployments:

```
export BOSH_ENVIRONMENT=<bosh-alias>
export BOSH_DEPLOYMENT=cf-containers-broker
git clone https://github.com/cloudfoundry-community/cf-containers-broker-boshrelease.git
bosh deploy cf-containers-broker-boshrelease/manifests/cf-containers-broker.yml
```

If your BOSH does not have Credhub/Config Server, then remember `--vars-store` to allow generation of passwords and certificates.

### Update

When new versions of `redis-boshrelease` are released the `manifests/redis.yml` file will be updated. This means you can easily `git pull` and `bosh deploy` to upgrade.

```
export BOSH_ENVIRONMENT=<bosh-alias>
export BOSH_DEPLOYMENT=cf-containers-broker
cd cf-containers-broker-boshrelease
git pull
cd -
bosh deploy cf-containers-broker-boshrelease/manifests/redis.yml
```
