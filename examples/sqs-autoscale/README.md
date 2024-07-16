# SQS Auto-Scaling Example

This workload will autoscale any workload based on an SQS queue length.

Multiple workloads can be configured. Each workload is scaled based on the length of one associated queue.

A `config.json` file (stored as an opaque secret named `sqs-autoscale`), contains the auto-scaling rules. See below for an example.

## Sample config.json

```json
[
  {
    "gvc": "default-gvc",
    "workloadName": "test-workload",
    "sqsEndpoint": "https://sqs.us-east-1.amazonaws.com/123456789012/queue1",
    "scalingRules": [
      { "length": 0, "scaleAmount": 2 },
      { "length": 10, "scaleAmount": 3 },
      { "length": 50, "scaleAmount": 4 },
      { "length": 101, "scaleAmount": 5 }
    ]
  }
]
```

Queue length of 0 to 9, will be scaled to 2. Length of 10-49, to 3.

## Building the Image

Use `cpln` to build and push the image. Authentication using `cpln login` and permissions to push an image is required.

`cpln image build --name sqs-autoscale:0.1 --org ORG_NAME --push`

## Configure CRON Workload

See `sample-workload.yaml` for a sample Control Plane YAML manifest file. The sample executes every minute.

## Identity Configuration

An identity is required to be associated with this workload with the following:

1. `Cloud Access` configured with read permissions to the SQS queues being inspected.

## Policy Configuration

The identity requires the following polices to be created:

1. `Reveal` permission to the secret containing the `config.json` contents.
2. `Manage` permission for the workloads being autoscaled.
