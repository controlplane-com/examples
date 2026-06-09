# Restart All Workloads in a GVC

## Overview

This example deploys a small cron-driven job that restarts every workload in the current GVC except the workload running the script itself.

At runtime, the script:

- reads `CPLN_ORG`, `CPLN_GVC`, `CPLN_TOKEN`, and `CPLN_WORKLOAD`
- lists workloads in the current GVC
- excludes the current workload from the restart list
- issues a `PATCH` to each remaining workload with a new `cpln/deployTimestamp`
- logs start, progress, success, and failure details to stdout/stderr
- exits non-zero if any workload fails to redeploy

The included Dockerfile builds a lightweight Alpine-based image with only the tools the script needs:

- `bash`
- `curl`
- `jq`
- CA certificates

This keeps the image small while still being suitable for a Control Plane cron workload.

## Prerequisites

- `cpln` CLI installed and logged in
- permission to build images in the target org
- permission to apply resources in the target org and GVC
- a target image repository in the org for `alpine-with-tools:0.1`

## Installation

You must be logged in with the `cpln` CLI and have the appropriate permissions to build images and apply resources in the target org and GVC before running these commands.

### 1. Build and push the container image

Build the image with the Control Plane CLI and tag it as `alpine-with-tools:0.1`:

```bash
cpln image build alpine-with-tools:0.1 . --push --org <org>
```

Using `--push` publishes the image to your organization’s repository as part of the build.

The Dockerfile is intentionally minimal. It starts from `alpine:latest`, updates the package index, upgrades installed packages, and installs the runtime tools needed by the script.

### 2. Apply the Control Plane manifest

Apply `cpln-restart-all-workloads.yaml`:

```bash
cpln apply -f cpln-restart-all-workloads.yaml --org <org> --gvc <gvc>
```

This manifest should deploy:

- the script as an opaque secret, which you can modify as needed
- the cron workload that runs every hour by default
- the identity used by the workload
- the policy that allows the identity to reveal the secret

You can customize the cron schedule in the manifest if you want the job to run more or less frequently.

Before applying the manifest, update the `CPLN_GVC` token placeholder in the YAML to the GVC where you want the job to run.

## Required policy bindings

In addition to the secret-reveal policy included with the example, you must create and bind a policy that targets the workloads you want restarted.

That policy must grant the cron workload’s identity the `manage` permission on the target workloads.

Without that binding, the script can list workloads and authenticate, but it will not be able to patch the workloads you want to redeploy.

## Runtime

- The cron workload runs every hour by default.
- You can customize the schedule in `cpln-restart-all-workloads.yaml`.
- After the workload is applied, you can update the YAML and apply it again, or use the Control Plane Console UI to change the schedule.
- The script skips the workload it is running in so it does not redeploy itself.
- If any workload fails to redeploy, the job continues through the remaining workloads and exits non-zero at the end.

## Secrets

- The script is stored in Control Plane as an opaque secret.
- If you modify the script, update the secret and reapply the manifest.
- The secret-reveal policy in the example only allows the workload identity to read the script secret.

## Environment variables

The script expects these runtime variables:

- `CPLN_ORG`
- `CPLN_GVC`
- `CPLN_TOKEN`
- `CPLN_WORKLOAD`

`CPLN_WORKLOAD` is used to identify the currently running workload so it can be excluded from the restart list.

When this script runs inside Control Plane, these environment variables are available by default and do not need to be added manually.

## Notes

- If the workload list request fails, the script prints the API error output and exits non-zero.
- If one or more workload redeploys fail, the script continues with the remaining workloads and exits non-zero at the end.
- The script is designed for container execution and exits when it finishes.

## Troubleshooting

- `cpln` login or permission errors usually mean the CLI session is missing or the identity lacks the required org/GVC access.
- If the workload list request fails, confirm `CPLN_ORG`, `CPLN_GVC`, and `CPLN_TOKEN` are valid for the target environment.
- If redeploys fail with authorization errors, make sure the workload-targeting policy grants the cron identity `manage` permission on the workloads you want restarted.
- If the job appears to do nothing, verify the `CPLN_GVC` value in the manifest and confirm the workload list for that GVC is not empty.

## Feature Requests

- Success or error notification via email, Slack, or a similar notification channel
