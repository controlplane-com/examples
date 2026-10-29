import { createServer, type IncomingMessage, type ServerResponse } from 'node:http';
import { createStore, DatabaseUnavailable } from './store.js';
import { runtime } from './runtime.js';

const PORT = Number(process.env.PORT ?? 8080);
const RECENT_LIMIT = 10;
const MAX_BODY_BYTES = 16 * 1024;
const MAX_EMAIL_LENGTH = 254;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const store = createStore();

class HttpError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

function send(res: ServerResponse, status: number, body: unknown) {
  const json = JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(json),
  });
  res.end(json);
}

async function readJson(req: IncomingMessage): Promise<Record<string, unknown>> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) {
      throw new HttpError(413, 'The request body is too large.');
    }
    chunks.push(chunk as Buffer);
  }
  try {
    const parsed: unknown = JSON.parse(Buffer.concat(chunks).toString('utf8') || '{}');
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('not an object');
    }
    return parsed as Record<string, unknown>;
  } catch {
    throw new HttpError(400, 'The request body must be a JSON object.');
  }
}

function normalizeEmail(value: unknown): string {
  const email = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (!EMAIL_PATTERN.test(email) || email.length > MAX_EMAIL_LENGTH) {
    throw new HttpError(400, 'A valid email address is required.');
  }
  return email;
}

async function handle(req: IncomingMessage, res: ServerResponse): Promise<number> {
  const method = req.method === 'HEAD' ? 'GET' : req.method;
  const path = new URL(req.url ?? '/', 'http://localhost').pathname.replace(/\/+$/, '') || '/';

  switch (`${method} ${path}`) {
    case 'GET /': {
      send(res, 200, { service: 'api', ...runtime, storage: store.kind });
      return 200;
    }
    case 'GET /signups': {
      const { count, signups } = await store.list(RECENT_LIMIT);
      send(res, 200, { storage: store.kind, workload: runtime.workload, location: runtime.location, count, signups });
      return 200;
    }
    case 'POST /signups': {
      const body = await readJson(req);
      const email = normalizeEmail(body.email);
      const signup = await store.add(email, runtime.location);
      if (!signup) {
        throw new HttpError(409, 'That address is already on the waitlist.');
      }
      send(res, 201, { signup });
      return 201;
    }
    default:
      throw new HttpError(404, `No route for ${req.method} ${path}.`);
  }
}

function statusFor(error: unknown): { status: number; message: string } {
  if (error instanceof HttpError) {
    return { status: error.status, message: error.message };
  }
  if (error instanceof DatabaseUnavailable) {
    return { status: 503, message: `The database is unavailable: ${error.message}` };
  }
  console.error(error);
  return { status: 500, message: 'Internal error.' };
}

const server = createServer(async (req, res) => {
  const started = performance.now();
  let status: number;
  try {
    status = await handle(req, res);
  } catch (error: unknown) {
    const failure = statusFor(error);
    status = failure.status;
    send(res, status, { error: failure.message });
  }
  console.log(`${req.method} ${req.url} ${status} ${Math.round(performance.now() - started)}ms`);
});

server.listen(PORT, () => {
  const target = process.env.PGHOST ? `postgres at ${process.env.PGHOST}` : 'memory';
  console.log(`api ${runtime.version} listening on port ${PORT} in ${runtime.location}, storage: ${target}`);
});

process.on('SIGTERM', () => {
  server.close(() => {
    store.close().finally(() => process.exit(0));
  });
});
