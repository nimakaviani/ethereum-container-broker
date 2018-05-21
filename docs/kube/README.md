# Using the broker with Kubernetes

This walkthrough assumes you have the broker up and running already.

As an Open Service Broker API compliant broker, it can be used with the (Kubernetes Service
Catalog)[http://github.com/kubernetes-incubator/service-catalog].  This README assumes you
have installed Service Catalog on top of your Kubernetes deployment. You may also wish to install
svcat, the Service Catalog CLI:

* [Linux](https://download.svcat.sh/cli/latest/linux/amd64/svcat)
* [OS X](https://download.svcat.sh/cli/latest/darwin/amd64/svcat)
* [Windows](https://download.svcat.sh/cli/latest/windows/amd64/svcat.exe)

Download the binary for your OS, ensure it's executable, and put it somewhere on your path.

# Installing the Broker

First, we need to create a secret that contains the creds to talk to the broker. Assuming you're
using the default username for the broker, you need to fill in the password field in secret.yaml.
Find out the properties.password from the subway-broker job from your bosh manifest, and then encode it in
base 64 like so:

```
echo PASSWORD | base64
```

Note that you'll need to do this for the username as well if you are not using the default username
of 'broker'. Then, put the resulting value(s) into secret.yaml, and create the secret like so:

```
kubectl create -f secret.yaml
```

Then, add the broker to your Kubernetes cluster by creating a file
that contains a specification of the broker, like so:
```
apiversion: servicecatalog.k8s.io/v1beta1
kind: ClusterServiceBroker
metadata:
  name: blockhead-broker
spec:
  url: http://insert-your-url-here.com
  authinfo:
    basic:
      secret: brokersecret
```

The url should be whatever URL your broker is running at. If you are using the CF Container Runtime
as your Kubernetes deployment and your broker is deployed using the same BOSH director, this could be
the internal URL of the docker vm from the broker deployment. Once you have the file filled out, run

```
kubectl create -f broker.yaml
```

to add the broker to your Kube cluster. Service Catalog will fetch the catalog, which should then
show up in svcat:
```
> svcat get classes
     NAME             DESCRIPTION             UUID     
+------------+---------------------------+------------+
  eth		Etherium Geth Node	   eth
```

You can then use svcat to provision an instance:

```
svcat provision myservice --class=eth --plan=free
svcat bind myservice --param="contract_url=http://contract-marketplace-url.com/path/to/contract"
```

After that, you can use the secret created by the bind in your pods and deployments to consume your contract info. See
additional Service Catalog documentation (here)[https://svc-cat.io/docs/walkthrough/].
