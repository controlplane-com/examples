# Example - Display Environment Variables

This example is a Node.js that will display all the environment variables available within a container.

## Steps To Run

1) Install the Control Plane CLI.
2) Log in:
```
cpln login
```
3) Containerize and push image to the org's private repository:
```
cpln image build --name cpln-env-vars:1 --push --ORG ORG_NAME
```
4) Create a new GVC (if necessary) that will host the Workload:
```
cpln gvc create --name GVC_NAME --location aws-us-west-2 --org ORG_NAME
```
5) Create a new Workload using the image from step #3 (the --public flag will enable inbound and outbound traffic through the external firewall):
```
cpln workload create --name onboarding2 --image //image/cpln-env-vars:1 --public --org ORG_NAME --gvc GVC_NAME
```
The output of the `workload create` command will contain the global endpoint URL. After a few minutes, browse to the URL
to execute the example.