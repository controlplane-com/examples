## envoyproxy examples

### custom routing

Creates an envoyproxy ingress gateway which routes traffic to different internally accessable workloads for different request paths and http methods.

#### Routing Rules

All requests starting with `/v1/blog/${id}/notes` -> `notes` workload
POST requests starting with `/v1/blog/${id}/comments` -> `addcomments` workload
GET requests starting with `/v1/blog/${id}/comments` -> `getcomments` workload
Any other request -> `default` workload

#### Steps to run this example:

**CLI**

```bash
cpln apply --gvc envoyproxy -f ./envoyproxy-custom-routing.yaml

# add a location to the GVC
cpln gvc add-location envoyproxy --location aws-us-east-2
```

**UI**

1. Create a GVC named `envoyproxy` and assign the location(s) that you would like to use.
1. Apply the `envoyproxy-custom-routing.yaml` file using the `cpln apply >_` option in the upper right corner. Open or paste the file contents. Scroll to the bottom and click apply.

#### Testing

We'll obtain the endpoint for the envoyproxy workload and use it to test out the various routes.

```bash
export ENDPOINT="https://envoyproxy-rw677jxx694cg.cpln.app"
curl -L  $ENDPOINT/v1/blog/12345/notes/
curl -L $ENDPOINT/v1/blog/12345/comments/foo
curl -L -X POST $ENDPOINT/v1/blog/12345/comments/foo
curl -L -X POST $ENDPOINT/any
```

Output

```bash
Hello /org/monitoring/gvc/envoyproxy/workload/notes!
Hello /org/monitoring/gvc/envoyproxy/workload/getcomments!
Hello /org/monitoring/gvc/envoyproxy/workload/addcomments!
Hello /org/monitoring/gvc/envoyproxy/workload/default!
```

#### Modifications

If the `envoy-config` secret is modified, run a force redeployment of the envoyproxy workload so that changes are applied immediately.

#### Cleanup

**CLI**

```bash
cpln delete --gvc envoyproxy -f ./envoyproxy-custom-routing.yaml
```

**UI**

1. Delete the GVC `envoyproxy`.
1. Delete the policy `envoyproxy`.
1. Delete the secret `envoyproxy-config`.
