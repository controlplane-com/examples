# Phone book

The demo app of the Control Plane onboarding. A small phone book that shows where it runs: the location that served the page, every location of its GVC and which of them are healthy, and whether a PostgreSQL database is connected. It deploys from a public image, so a new user's AI agent can run it in a minute without building anything.

## What it shows

- **Served from**: the cloud and city of the location that answered, with the location's name under them. Suspend a location and the page switches to another one.
- **Locations**: every location of the GVC, marked "Serving you", "Healthy", or "Unavailable". Each other healthy location links to its own endpoint, so you can open the app served from there, and "Global endpoint" opens the address that routes to the nearest healthy location.
- **Database**: PostgreSQL connected, unreachable (with the reason), or none. Without a database, contacts live in memory on the replica that stored them, so each location keeps its own list and a restart empties it.
- **Contacts**: add, search, and delete. Each contact is stamped with the location that stored it.
- Light and dark themes, following the system until the toggle picks one.

## What Control Plane provides

Everything the page shows about the platform comes from the [variables Control Plane injects](https://docs.controlplane.com/reference/workload/general#built-in-variables) into the container and from the Control Plane API. Nothing is hard-coded.

| Variable | Used for |
| --- | --- |
| `CPLN_LOCATION` | The location serving the page. Arrives as a link (`/org/ORG/location/NAME`); the app keeps the name |
| `CPLN_PROVIDER` | The cloud of that location |
| `CPLN_ORG`, `CPLN_GVC`, `CPLN_WORKLOAD` | The paths of the API calls below, and the GVC named above the locations |
| `CPLN_WORKLOAD_VERSION`, `CPLN_IMAGE` | The footer, so a rollout shows the new version and image |
| `CPLN_GLOBAL_ENDPOINT` | The "Global endpoint" link |
| `CPLN_ENDPOINT`, `CPLN_TOKEN` | The Control Plane API, called with the workload's own token as a bearer token |

| API call | Gives |
| --- | --- |
| `GET /org/ORG/gvc/GVC` | The GVC's locations |
| `GET /org/ORG/gvc/GVC/workload/WORKLOAD/deployment` | Each location's health (`status.ready`) and its own endpoint (`status.endpoint`) |
| `GET /org/ORG/location/NAME` | The city and country, from the location's built-in `cpln/city` and `cpln/country` tags |

## Seeing every location

`CPLN_TOKEN` acts as the workload's identity, and without a policy it can only read its parent org. The page then shows only its own location, without a city, and says why. To show everything:

1. Give the workload an identity.
2. Grant that identity `view` on the GVC, on the workload, and on locations, with a policy for each.

The page updates within five seconds. Nothing else in the app needs this access.

## Routes

| Route | Answer |
| --- | --- |
| `GET /` | The page |
| `GET /api/status` | Location, cloud, city, workload, version, image, global endpoint, database status, and the locations of the GVC |
| `GET /api/contacts` | Up to 200 contacts, sorted by name |
| `POST /api/contacts` | Stores `{ "name": "...", "phone": "..." }`; answers `201`, or `400` for an invalid name or phone |
| `DELETE /api/contacts/:id` | Deletes a contact; answers `204`, or `404` |
| `GET /healthz` | `200` while the process is up |

## Configuration

| Variable | Purpose |
| --- | --- |
| `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE` | PostgreSQL connection, read by the `pg` client. With `PGHOST` set the app stores contacts in PostgreSQL and creates its table on first use; without it, in memory |
| `PORT` | Listening port, default `8080` |

## Run locally

Outside Control Plane the `CPLN_*` variables are absent, so the page says it is served from this computer.

```bash
npm install
npm run build
npm start
```

With PostgreSQL in Docker:

```bash
docker run -d --name phonebook-pg -e POSTGRES_USER=phonebook -e POSTGRES_PASSWORD=local -e POSTGRES_DB=phonebook -p 55432:5432 postgres:16-alpine
PGHOST=localhost PGPORT=55432 PGUSER=phonebook PGPASSWORD=local PGDATABASE=phonebook npm start
```

## Image

The public image is `ghcr.io/controlplane-com/examples/phonebook`, for `linux/amd64`, tagged with the version in `package.json` and `latest`. The [publish workflow](../../../.github/workflows/phonebook-image.yml) pushes it when a change here reaches `main`, and refuses a version that is already published, so bump `version` with every change.

To build it yourself, from this directory, with Docker running:

```bash
docker build --platform linux/amd64 -t phonebook:dev .
docker run --rm -p 8080:8080 phonebook:dev
```

## License

[Apache 2.0](./LICENSE), like the rest of this repository.
