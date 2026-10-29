# Quickstart frontend

The launch page built in part 2 of the [Control Plane quickstart](https://docs.controlplane.com/quickstart/deploy-application). A Next.js site for a product that is about to launch, with a waitlist served by the [quickstart API](https://docs.controlplane.com/quickstart/connect-workloads) over the internal network. It is never published as an image: you build it into your own org's registry.

## What it shows

- The product name, tagline, description, and three features from `site.config.ts`. Edit them, rebuild, and update the workload to watch a change roll out.
- Which location served the request, from the `CPLN_LOCATION` variable Control Plane injects, plus the workload name and version.
- A "Runs on Control Plane" badge in the navbar and a "Provided by Control Plane" credit in the footer, both with the Control Plane logomark. The favicon is the product's initial, generated in `app/icon.tsx`, so it follows a rename. The colors follow the Control Plane brand.
- The waitlist: a signup form and the latest signups, each stamped with the location of the API replica that stored it. Until an API is connected the form is disabled and the page says so. If the API cannot be reached, or answers with an error, the page says which.

## Configuration

| Variable | Purpose |
| --- | --- |
| `API_URL` | Base URL of the API workload, for example `http://api.quickstart-gvc.cpln.local:8080` |
| `PORT` | Listening port, default `8080` |

`API_URL` is optional. Without it the site renders with the waitlist closed. The page calls the API only on the server, so the API never has to be public.

## Run locally

```bash
npm install
npm run dev
```

## Build the image

From this directory, with Docker running:

```bash
cpln image build --name frontend:1.0 --push
```

Without Docker, build on Control Plane instead:

```bash
cpln image build --name frontend:1.0 --remote
```

There is no Dockerfile: the build detects the Node.js project from its source, through Buildpacks with Docker and through the Control Plane build service with `--remote`.
