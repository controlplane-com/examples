## Redis Sentinel Example

This example creates highly-available Redis workload on the Control Plane platform. One replica is the master, and two
others are read-only replicas. A trio of sentinels monitors the master. In the event of a master failure, the sentinels
will elect and promote one of the read-only replicas to master.

### Steps to run this example:~~~~
**HELM**

The [Helm CLI](https://helm.sh/docs/intro/install/#through-package-managers) and [Control Plane CLI](https://docs.controlplane.com/reference/cli#install-npm) must be installed.

1. Clone this repo and update the [values.yaml](values.yaml) file as needed.

2. Run the command below from this directory.

   ```bash
   cpln helm install redis-sentinel --gvc mygvc [--org myorg]
   ```

### Accessing redis-sentinel

Workloads are allowed to access Redis Sentinel based on the `firewallConfig` you specify. You can learn more about in our [documentation](https://docs.controlplane.com/reference/workload#internal).

__Important__: To access workloads listening on a TCP port, the client workload must be in the same GVC. Thus, Redis is only accessible to clients running within the same GVC.

You should configure the client to connect to the sentinels as shown in the Typescript example below. The client will be
redirected to the current Redis master by the sentinels. It's important to tolerate errors gracefully so that there will be little or no disruption
in the event of a failover

```typescript
import Redis from "ioredis";

// Sentinel configuration
const redisConfig = {
   sentinels: [
      { host: "redis-sentinel-0.redis-sentinel", port: 26379 },
      { host: "redis-sentinel-1.redis-sentinel", port: 26379 },
      { host: "redis-sentinel-2.redis-sentinel", port: 26379 },
   ],
   name: "mymaster", // Replace with your Redis master name
   reconnectOnError: (err: Error) => {
      console.error("Redis connection error:", err.message);
      return true; // Always reconnect on errors
   },
   sentinelRetryStrategy: (times: number) => {
      console.warn(`Retrying Sentinel connection (${times})`);
      return Math.min(times * 100, 2000); // Wait longer with each retry, up to 2 seconds
   },
};

async function main() {
   const redis = new Redis(redisConfig);
   // Listen for failover and connection events
   redis.on("connect", () => console.log("Connected to Redis"));
   redis.on("reconnecting", (time:string) =>
           console.log(`Reconnecting to Redis in ${time}ms`)
   );
   redis.on("error", (err) => console.error("Redis error:", err));

   try {
      // Set key-value pair
      await redis.set("foo", "bar");
   } catch (err) {
      console.error("Error setting key:", err);
   }
}

main().catch((err) => {
   console.error("Fatal error in main function:", err);
   process.exit(1);
});
```

### Cleanup

**HELM**

```bash
cpln helm uninstall redis-cluster
```
