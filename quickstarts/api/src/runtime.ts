// Control Plane injects these into every container. Locally they are absent.
// Location and workload arrive as links (/org/my-org/location/aws-us-west-2); the API reports the last segment.
function lastSegment(link: string | undefined) {
  return link ? link.split('/').filter(Boolean).pop() : undefined;
}

export const runtime = {
  location: lastSegment(process.env.CPLN_LOCATION) ?? 'local',
  workload: lastSegment(process.env.CPLN_WORKLOAD) ?? 'api',
  version: process.env.CPLN_WORKLOAD_VERSION ?? 'dev',
};
