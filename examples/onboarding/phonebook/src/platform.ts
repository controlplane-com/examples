import { providerOf, runtime } from './runtime.js';

export type LocationHealth = {
  name: string;
  provider: string;
  // "City, Country" from the location's built-in tags; null when they cannot be read.
  place: string | null;
  healthy: boolean;
  current: boolean;
  // The location's own endpoint, from its deployment's status; null when there is none to open.
  endpoint: string | null;
};

// `all` lists every location of the GVC. Otherwise only this replica's location is known, and `reason` says why.
export type LocationsView =
  | { all: true; items: LocationHealth[] }
  | { all: false; reason: 'local' | 'no-access' | 'unavailable'; items: LocationHealth[] };

const VIEW_TTL_MS = 5_000;
// A location's tags change only when Control Plane moves it, so they are read far less often.
const PLACE_TTL_MS = 10 * 60_000;
const REQUEST_TIMEOUT_MS = 3_000;

class NoAccess extends Error {}

let cachedView: { at: number; value: LocationsView } | null = null;
// Holds the request itself, so the page and the locations list asking at once read a location's tags once.
const cachedPlaces = new Map<string, { at: number; value: Promise<string | null> }>();

function onControlPlane(): boolean {
  return Boolean(runtime.apiEndpoint && runtime.apiToken && runtime.org);
}

function lastSegment(link: string): string {
  return link.split('/').filter(Boolean).pop() ?? link;
}

function record(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === 'object' ? (value as Record<string, unknown>) : {};
}

// The workload's token is sent the way the cpln CLI sends it, as a bearer token.
async function get(path: string): Promise<unknown> {
  const token = runtime.apiToken!.startsWith('Bearer ') ? runtime.apiToken! : `Bearer ${runtime.apiToken}`;
  const response = await fetch(`${runtime.apiEndpoint}/org/${encodeURIComponent(runtime.org!)}${path}`, {
    headers: { Authorization: token, Accept: 'application/json' },
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  if (response.status === 401 || response.status === 403) {
    throw new NoAccess();
  }
  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}`);
  }
  return response.json();
}

// Reads the built-in `cpln/city` and `cpln/country` tags of a location. That needs `view` on locations; without it
// the page shows the cloud only.
export function placeOf(location: string): Promise<string | null> {
  const cached = cachedPlaces.get(location);
  if (cached && Date.now() - cached.at < PLACE_TTL_MS) {
    return cached.value;
  }

  const value = readPlace(location);
  cachedPlaces.set(location, { at: Date.now(), value });
  return value;
}

async function readPlace(location: string): Promise<string | null> {
  if (!onControlPlane()) {
    return null;
  }
  try {
    const tags = record(record(await get(`/location/${encodeURIComponent(location)}`)).tags);
    const parts = [tags['cpln/city'], tags['cpln/country']].filter((part) => typeof part === 'string' && part !== '');
    return parts.length > 0 ? parts.join(', ') : null;
  } catch {
    return null;
  }
}

function only(reason: 'local' | 'no-access' | 'unavailable', place: string | null): LocationsView {
  const current = {
    name: runtime.location,
    provider: runtime.provider,
    place,
    healthy: true,
    current: true,
    endpoint: null,
  };
  return { all: false, reason, items: [current] };
}

// Reads the GVC's locations and the workload's deployments with the workload's own token. That needs `view` on the GVC
// and on the workload, granted to the workload's identity; without it only this replica's location is shown.
async function fromControlPlane(): Promise<LocationsView> {
  const gvcPath = `/gvc/${encodeURIComponent(runtime.gvc!)}`;
  const [gvcItem, deployments] = await Promise.all([
    get(gvcPath),
    get(`${gvcPath}/workload/${encodeURIComponent(runtime.workload)}/deployment`),
  ]);

  const placement = record(record(record(gvcItem).spec).staticPlacement);
  const links = Array.isArray(placement.locationLinks) ? placement.locationLinks : [];
  const ready = new Map<string, boolean>();
  const endpoints = new Map<string, string>();

  for (const deployment of Array.isArray(record(deployments).items) ? (record(deployments).items as unknown[]) : []) {
    const item = record(deployment);
    const status = record(item.status);
    const name = String(item.name ?? '');
    ready.set(name, status.ready === true);
    if (typeof status.endpoint === 'string' && status.endpoint !== '') {
      endpoints.set(name, status.endpoint);
    }
  }

  const names = (links.length > 0 ? links.map((link) => lastSegment(String(link))) : [...ready.keys()]).sort();
  const places = await Promise.all(names.map(placeOf));
  const items = names.map((name, index) => ({
    name,
    provider: providerOf(name),
    place: places[index] ?? null,
    healthy: ready.get(name) === true,
    current: name === runtime.location,
    endpoint: endpoints.get(name) ?? null,
  }));

  return { all: true, items };
}

export async function locations(): Promise<LocationsView> {
  if (cachedView && Date.now() - cachedView.at < VIEW_TTL_MS) {
    return cachedView.value;
  }

  let value: LocationsView;

  if (!onControlPlane() || !runtime.gvc) {
    value = only('local', null);
  } else {
    try {
      value = await fromControlPlane();
    } catch (cause) {
      value = only(cause instanceof NoAccess ? 'no-access' : 'unavailable', await placeOf(runtime.location));
    }
  }

  cachedView = { at: Date.now(), value };
  return value;
}
