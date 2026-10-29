// What Control Plane injects into every container (https://docs.controlplane.com/reference/workload/general#built-in-variables).
// Locally they are absent. Some arrive as links (/org/my-org/location/aws-us-west-2); the app keeps the last segment.
function lastSegment(value: string | undefined): string | undefined {
  return value ? value.split('/').filter(Boolean).pop() : undefined;
}

// The docs show CPLN_GLOBAL_ENDPOINT as a bare host, but it arrives with its scheme; a bare host gets https.
function urlOf(value: string | undefined): string | null {
  if (!value) {
    return null;
  }

  return /^[a-z][a-z0-9+.-]*:\/\//i.test(value) ? value : `https://${value}`;
}

export function providerOf(location: string): string {
  return location.split('-')[0] ?? location;
}

const location = lastSegment(process.env.CPLN_LOCATION) ?? 'local';

export const runtime = {
  org: lastSegment(process.env.CPLN_ORG),
  gvc: lastSegment(process.env.CPLN_GVC),
  workload: lastSegment(process.env.CPLN_WORKLOAD) ?? 'phonebook',
  location,
  provider: process.env.CPLN_PROVIDER ?? (location === 'local' ? 'local' : providerOf(location)),
  version: process.env.CPLN_WORKLOAD_VERSION ?? 'dev',
  image: process.env.CPLN_IMAGE ?? null,
  // The workload's global URL, routed to the nearest healthy location.
  globalEndpoint: urlOf(process.env.CPLN_GLOBAL_ENDPOINT),
  // The Control Plane API as seen from inside the workload; the token works only from this workload.
  apiEndpoint: process.env.CPLN_ENDPOINT,
  apiToken: process.env.CPLN_TOKEN,
};
