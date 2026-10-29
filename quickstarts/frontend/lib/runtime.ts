// Control Plane injects these into every container. Locally they are absent.
// Location and workload arrive as links (/org/my-org/location/aws-us-west-2); the page shows the last segment.
function lastSegment(link: string | undefined) {
  return link ? (link.split('/').filter(Boolean).pop() ?? null) : null;
}

export function runtime() {
  return {
    location: lastSegment(process.env.CPLN_LOCATION),
    workload: lastSegment(process.env.CPLN_WORKLOAD),
    version: process.env.CPLN_WORKLOAD_VERSION ?? null,
  };
}
