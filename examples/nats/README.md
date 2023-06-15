## nats.io examples

#### nats-jetstream-stateful

Creates a 3 node nats.io cluster with jetstream enabled and persistent storage

Service discovery is made using the stateful workload service endpoint of `nats` and the unique `$HOSTNAME` environment variable for each replica.

These names will be `nats-0`, `nats-1` and `nats-2` at runtime.

##### Steps to run this example:

###### cli

```bash
cpln apply --gvc nats -f ./nats-jetstream-stateful.yaml
cpln gvc add-location nats --location aws-us-east-2
```

###### ui

1. Create a GVC named `nats` and assign the location(s) that you would like to use.
1. Apply the `nats-jetstream-stateful.yaml` file using the `cpln apply >_` option in the upper right corner.

##### cleanup:

###### cli

```bash
cpln delete --gvc nats -f ./nats-jetstream-stateful.yaml
```

###### ui

1. delete the gvc `nats`.
1. delete the policy `nats`.
1. delete the secret `nats-config`.
