# Quickstart API

The API built in part 3 of the [Control Plane quickstart](https://docs.controlplane.com/quickstart/connect-workloads). It stores the waitlist signups for the [quickstart frontend](https://docs.controlplane.com/quickstart/deploy-application), in memory until [part 4](https://docs.controlplane.com/quickstart/database-and-secrets) connects a PostgreSQL database. It runs as an internal workload: only the frontend reaches it, over the internal network. It is never published as an image: you build it into your own org's registry.

## Routes

| Route | Answer |
| --- | --- |
| `GET /` | The service name, version, location, workload, and which storage is in use |
| `GET /signups` | The signup count and the ten latest signups, each stamped with the location that stored it |
| `POST /signups` | Stores `{ "email": "..." }`; answers `201`, `400` for an invalid address, or `409` for an address already on the list |

## Configuration

| Variable | Purpose |
| --- | --- |
| `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` | PostgreSQL connection, read by the `pg` client. With `PGHOST` set the API stores signups in PostgreSQL and creates its table on first use; without it, in memory |
| `PORT` | Listening port, default `8080` |

## Run locally

```bash
npm install
npm run build
npm start
```

## Build the image

From this directory, with Docker running:

```bash
cpln image build --name api:1.0 --push
```

Without Docker, build on Control Plane instead:

```bash
cpln image build --name api:1.0 --remote
```

There is no Dockerfile: the build detects the Node.js project from its source and runs its `build` script, through Buildpacks with Docker and through the Control Plane build service with `--remote`.
