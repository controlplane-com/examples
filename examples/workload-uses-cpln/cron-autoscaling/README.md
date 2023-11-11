## Modify the yaml to match you needs

1. Update `${GVC}` to the GVC you need to apply this to.
1. Update the `WORKLOAD` environment variable to the workload you'd like to scale.
1. Update the `TARGET` environment variable to the new minScale that will be set on the workload.
1. Adjust the cron schedule as needed.

## create the cron workloads

```bash
cpln apply -f ./cpln-cron-workload.yaml
```

# optional

## build and push the image

```bash
cpln image build --name cpln:v1.3.2 --push
```
