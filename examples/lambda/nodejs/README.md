## Typescript Lambda to CPLN

AWS Lambda is a serverless computing service provided by AWS that allows you to run code in response to triggers without having to manage servers.
These programs can easily and quickly be translated to CPLN compatible projects.
Running on Control Plane, these systems have much greater customizability.

### Requirements

- [Control Plane Account](https://controlplane.com)
- [CLI](https://docs.controlplane.com/reference/cli)
- [GVC](https://docs.controlplane.com/reference/gvc)

### Steps

1. Containerize your lambda handlers.

- _Replace handler file(s) as needed_

```bash
npx lambda2cpln ./handler.ts
```

2. Build and push image using the newly created cpln directory.

- _Replace `lambda:1.0` with a name for your image._

```bash
cd cpln
cpln image build --push --name lambda:1.0 --org <your org>
```

3. Create a workload.

- _Replace `lambda` with a name for the workload._
- _Replace `lambda:1.0` with the name of the image from step 2._

```bash
cpln workload create --name lambda --image lambda:1.0 --public --org <your org> --gvc <your gvc>
```

### Trigger

To trigger one of the handlers, send an http post request to the deployment endpoint.
The path of the request is the name of the handler.
The name of the handler is either the filename (if its not index), or the name of the parent directory.

- _Replace `handler` with the name of your handler_

```bash
curl -X POST <your deployment link>/handler -d '{"foo":"bar"}'
```

### Notes

- The body of the request can be found under `event.body` (as a string)
- Path parameters are not supported. Please use query strings instead.  
  These can be found under `event.queryStringParameters` (as an object)
- These steps work identically for handlers written in Javascript
