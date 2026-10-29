import { headers } from 'next/headers';

export type Signup = {
  id: number;
  email: string;
  location: string;
  createdAt: string;
};

export type Waitlist = {
  storage: 'memory' | 'postgres';
  workload: string;
  location: string;
  count: number;
  signups: Signup[];
};

export type ApiResult<T> =
  | { status: 'unconfigured' }
  | { status: 'unreachable'; url: string; reason: string }
  | { status: 'rejected'; url: string; httpStatus: number; message: string }
  | { status: 'ok'; data: T };

const REQUEST_TIMEOUT_MS = 3000;

// Forwarding the incoming trace headers joins this request and the API call into one trace.
const TRACE_HEADERS = [
  'traceparent',
  'tracestate',
  'x-request-id',
  'x-b3-traceid',
  'x-b3-spanid',
  'x-b3-parentspanid',
  'x-b3-sampled',
  'x-b3-flags',
];

// Node reports network failures as "fetch failed" with the real reason in the cause, which for a
// refused connection is an AggregateError whose own message is empty.
function describe(error: unknown): string {
  if (!(error instanceof Error)) {
    return String(error);
  }
  if (error.name === 'TimeoutError') {
    return `no answer within ${REQUEST_TIMEOUT_MS / 1000} seconds`;
  }
  const cause = error.cause as { code?: string; message?: string; errors?: { message?: string }[] } | undefined;
  const message = cause?.message || cause?.errors?.[0]?.message || error.message;
  const code = cause?.code;
  return code && !message.includes(code) ? `${message} (${code})` : message;
}

async function traceHeaders(): Promise<Headers> {
  const incoming = await headers();
  const outgoing = new Headers();
  for (const name of TRACE_HEADERS) {
    const value = incoming.get(name);
    if (value) {
      outgoing.set(name, value);
    }
  }
  return outgoing;
}

async function request<T>(path: string, init: RequestInit = {}): Promise<ApiResult<T>> {
  const base = process.env.API_URL;
  if (!base) {
    return { status: 'unconfigured' };
  }

  const outgoing = await traceHeaders();
  outgoing.set('Accept', 'application/json');
  if (init.body) {
    outgoing.set('Content-Type', 'application/json');
  }

  let response: Response;
  try {
    response = await fetch(new URL(path, base), {
      ...init,
      headers: outgoing,
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      cache: 'no-store',
    });
  } catch (error: unknown) {
    return { status: 'unreachable', url: base, reason: describe(error) };
  }

  if (!response.ok) {
    let message = response.statusText;
    try {
      const body = (await response.json()) as { error?: string };
      message = body.error ?? message;
    } catch {
      // A non-JSON error body keeps the status text.
    }
    return { status: 'rejected', url: base, httpStatus: response.status, message };
  }

  return { status: 'ok', data: (await response.json()) as T };
}

export function getWaitlist(): Promise<ApiResult<Waitlist>> {
  return request<Waitlist>('/signups');
}

export function joinWaitlist(email: string): Promise<ApiResult<{ signup: Signup }>> {
  return request<{ signup: Signup }>('/signups', { method: 'POST', body: JSON.stringify({ email }) });
}
