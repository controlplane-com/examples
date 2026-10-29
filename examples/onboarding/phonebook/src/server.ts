import { createServer, type IncomingMessage, type ServerResponse } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { locations, placeOf } from './platform.js';
import { runtime } from './runtime.js';
import { createStore, DatabaseUnavailable } from './store.js';

const PORT = Number(process.env.PORT ?? 8080);
const PUBLIC_DIR = fileURLToPath(new URL('../public/', import.meta.url));
const LIST_LIMIT = 200;
const MAX_BODY_BYTES = 16 * 1024;
const MAX_NAME_LENGTH = 80;
const MAX_PHONE_LENGTH = 32;
const PHONE_PATTERN = /^\+?[\d\s().-]+$/;
const MIN_PHONE_DIGITS = 3;

const STATIC_FILES: Record<string, string> = {
  '/': 'index.html',
  '/app.css': 'app.css',
  '/app.js': 'app.js',
  '/control-plane-mark.svg': 'control-plane-mark.svg',
};

const CONTENT_TYPES: Record<string, string> = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.svg': 'image/svg+xml',
};

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
    'Cache-Control': 'no-store',
  });
  res.end(json);
}

async function sendFile(res: ServerResponse, file: string) {
  const content = await readFile(join(PUBLIC_DIR, file));
  res.writeHead(200, {
    'Content-Type': CONTENT_TYPES[extname(file)] ?? 'application/octet-stream',
    'Content-Length': content.length,
    'Cache-Control': 'no-cache',
  });
  res.end(content);
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

function readName(value: unknown): string {
  const name = typeof value === 'string' ? value.trim().replace(/\s+/g, ' ') : '';
  if (name.length === 0 || name.length > MAX_NAME_LENGTH) {
    throw new HttpError(400, `A name of 1 to ${MAX_NAME_LENGTH} characters is required.`);
  }
  return name;
}

function readPhone(value: unknown): string {
  const phone = typeof value === 'string' ? value.trim().replace(/\s+/g, ' ') : '';
  const digits = phone.replace(/\D/g, '').length;
  if (!PHONE_PATTERN.test(phone) || phone.length > MAX_PHONE_LENGTH || digits < MIN_PHONE_DIGITS) {
    throw new HttpError(400, 'A phone number of digits, spaces, +, -, ( and ) is required.');
  }
  return phone;
}

async function status() {
  const [database, places, place] = await Promise.all([store.status(), locations(), placeOf(runtime.location)]);
  return {
    gvc: runtime.gvc ?? null,
    workload: runtime.workload,
    version: runtime.version,
    image: runtime.image,
    globalEndpoint: runtime.globalEndpoint,
    location: runtime.location,
    provider: runtime.provider,
    place,
    database,
    locations: places,
  };
}

async function handle(req: IncomingMessage, res: ServerResponse): Promise<void> {
  const url = new URL(req.url ?? '/', 'http://localhost');
  const method = req.method ?? 'GET';
  const file = STATIC_FILES[url.pathname];

  if (method === 'GET' && file) {
    return sendFile(res, file);
  }

  if (method === 'GET' && url.pathname === '/healthz') {
    return send(res, 200, { ok: true });
  }

  if (method === 'GET' && url.pathname === '/api/status') {
    return send(res, 200, await status());
  }

  if (method === 'GET' && url.pathname === '/api/contacts') {
    return send(res, 200, { contacts: await store.list(LIST_LIMIT) });
  }

  if (method === 'POST' && url.pathname === '/api/contacts') {
    const body = await readJson(req);
    const contact = await store.add(readName(body.name), readPhone(body.phone), runtime.location);
    return send(res, 201, contact);
  }

  const match = /^\/api\/contacts\/(\d+)$/.exec(url.pathname);

  if (method === 'DELETE' && match) {
    const removed = await store.remove(Number(match[1]));
    if (!removed) {
      throw new HttpError(404, 'There is no such contact.');
    }
    res.writeHead(204).end();
    return;
  }

  throw new HttpError(404, 'Not found.');
}

const server = createServer((req, res) => {
  handle(req, res).catch((cause: unknown) => {
    if (cause instanceof HttpError) {
      return send(res, cause.status, { error: cause.message });
    }
    if (cause instanceof DatabaseUnavailable) {
      return send(res, 503, { error: `The database is unavailable: ${cause.message}` });
    }
    console.error(cause);
    send(res, 500, { error: 'Something went wrong.' });
  });
});

server.listen(PORT, () => {
  console.log(
    `phonebook listening on ${PORT}: location ${runtime.location}, workload ${runtime.workload}, storage ${store.kind}`,
  );
});

function shutdown() {
  server.close(() => {
    store.close().finally(() => process.exit(0));
  });
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
