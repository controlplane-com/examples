# DESCRIPTION

This example showcases how to deploy a create-react-app UI and also how to use AWS Services within Control Plane. This specific example uses AWS DynamoDB.

# GETTING STARTED

Steps to make it work;

- Set up AWS Cloudaccount
- Create an Identity similar to below YAML file by changing MY_ORG accordingly, also see the AWS PolicyRefs info

```yaml
name: aws-dynamodb
kind: identity
aws:
  cloudAccountLink: /org/MY_ORG/cloudaccount/aws
  policyRefs:
    - "aws::AmazonDynamoDBFullAccess"
```

- Make sure you set up your account with `cpln image docker-login --org <ORG_NAME>`
- Build and push the image with the command below, when you are in the `todo-react-express` folder

```
cpln image build --name todo-app --tag v1 --push
```

- Set up the workload similar to below YAML file, changing MY_ORG and MY_GVC accordingly.

Key points are that outbound and inbound traffic is allowed and the capacity AI is disabled.

```yaml
name: todo-app
kind: workload
description: example todo app to learn about controlplane
spec:
  containers:
    - args: []
      cpu: 50m
      env:
        - name: TABLE_NAME
          value: todo-db
      image: "/org/MY_ORG/image/todo-app:v15"
      memory: 128Mi
      name: main
      ports:
        - number: 3001
          protocol: http
      readinessProbe:
        failureThreshold: 3
        httpGet:
          httpHeaders: []
          path: /
          port: 3001
          scheme: HTTP
        initialDelaySeconds: 0
        periodSeconds: 2
        successThreshold: 1
        timeoutSeconds: 1
  defaultOptions:
    autoscaling:
      maxConcurrency: 1000
      maxScale: 1
      metric: rps
      minScale: 1
      scaleToZeroDelay: 300
      target: 5000
    capacityAI: false
    debug: false
    timeoutSeconds: 120
  firewallConfig:
    external:
      inboundAllowCIDR:
        - 0.0.0.0/0
      outboundAllowCIDR:
        - 0.0.0.0/0
      outboundAllowHostname: []
    internal:
      inboundAllowType: none
      inboundAllowWorkload: []
  identityLink: /org/MY_ORG/gvc/MY_GVC/identity/aws-dynamodb
```

## Environment Variables

TABLE_NAME decides on the table name and default value is "todo-db" if not provided

## KNOWN ISSUES

It might fail when capacity ai is set to true

Website is not loaded correct when using deployment specific urls, because the controlplane doesn't handle relative urls correctly yet.
