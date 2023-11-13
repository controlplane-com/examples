# Load Test
This test comes in two parts:
1. Server - A simple "Hello World" HTTP server provided by Control Plane
2. Client - A Cron workload used to run load tests against the server on demand.

# How to Run the Load Test
## Step 1: Create the client and server workloads 
To apply the server, run `cpln apply -f server.yaml --org {YOUR_ORG_NAME_HERE} --gvc load-test-server`
To apply the client, run `cpln apply -f client.yaml --org {YOUR_ORG_NAME_HERE} --gvc load-test-client`

## Step 2: Create one or more load test commands
The workload in `client.yaml` (`load-test-cron`) is created in a suspended state, which means it will only run when commanded to.
This can be done by creating a `command` object in the Control Plane API. To create your first command, run: 
`cpln rest post /org/{YOUR_ORG_HERE}/gvc/load-test-client/workload/load-test-cron/-command --file simple-command.yaml`

This will begin a five-minute-long load test against the server workload. You can see the job execution in progress in the
Control Plane Console. Navigate to the load-test-client gvc, click "Workloads" in the main navigation menu, click load-test-cron, and finally on "Job Executions".
Note: the load test is only executing in the location specified in simple-command.yaml. To run a load test against all locations, you will need to create
one command for each location.

### Customize the load test command
This test uses a powerful load testing tool called [k6](https://k6.io). So, optionally, you can override the load test command to change (among other things)
- The number of virtual users
- The duration of the test
- The test script itself

For an example, see `advanced-command.yaml`