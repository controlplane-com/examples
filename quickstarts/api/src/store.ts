import pg from 'pg';

export type Signup = {
  id: number;
  email: string;
  location: string;
  createdAt: string;
};

export type Page = {
  count: number;
  signups: Signup[];
};

export interface Store {
  readonly kind: 'memory' | 'postgres';
  list(limit: number): Promise<Page>;
  // Resolves to null when the address is already on the list.
  add(email: string, location: string): Promise<Signup | null>;
  close(): Promise<void>;
}

// A refused connection arrives as an AggregateError with an empty message and the reason in its parts.
function reasonOf(cause: unknown): string {
  if (!(cause instanceof Error)) {
    return String(cause);
  }
  const parts = (cause as { errors?: unknown[] }).errors ?? [];
  const first = parts.find((part) => part instanceof Error) as Error | undefined;
  return cause.message || first?.message || (cause as { code?: string }).code || cause.name;
}

export class DatabaseUnavailable extends Error {
  constructor(cause: unknown) {
    super(reasonOf(cause));
    this.name = 'DatabaseUnavailable';
  }
}

class MemoryStore implements Store {
  readonly kind = 'memory' as const;
  private readonly signups = new Map<string, Signup>();
  private nextId = 1;

  async list(limit: number): Promise<Page> {
    const newestFirst = [...this.signups.values()].reverse();
    return { count: newestFirst.length, signups: newestFirst.slice(0, limit) };
  }

  async add(email: string, location: string): Promise<Signup | null> {
    if (this.signups.has(email)) {
      return null;
    }
    const signup = { id: this.nextId++, email, location, createdAt: new Date().toISOString() };
    this.signups.set(email, signup);
    return signup;
  }

  async close(): Promise<void> {}
}

type Row = { id: number; email: string; location: string; created_at: Date };

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS signups (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    location TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
  )`;

function toSignup(row: Row): Signup {
  return { id: row.id, email: row.email, location: row.location, createdAt: row.created_at.toISOString() };
}

// The pool reads PGHOST, PGPORT, PGUSER, PGPASSWORD, and PGDATABASE from the environment.
class PostgresStore implements Store {
  readonly kind = 'postgres' as const;
  private readonly pool = new pg.Pool();
  private schemaReady: Promise<void> | null = null;

  constructor() {
    // An idle connection the server drops surfaces here; the next query reconnects.
    this.pool.on('error', (error: Error) => console.error(`database connection lost: ${error.message}`));
  }

  private ensureSchema(): Promise<void> {
    this.schemaReady ??= this.pool
      .query(SCHEMA)
      .then(() => undefined)
      .catch((error: unknown) => {
        this.schemaReady = null;
        throw error;
      });
    return this.schemaReady;
  }

  private async run<T>(work: () => Promise<T>): Promise<T> {
    try {
      await this.ensureSchema();
      return await work();
    } catch (error: unknown) {
      throw new DatabaseUnavailable(error);
    }
  }

  list(limit: number): Promise<Page> {
    return this.run(async () => {
      const [total, recent] = await Promise.all([
        this.pool.query<{ count: string }>('SELECT count(*)::text AS count FROM signups'),
        this.pool.query<Row>('SELECT id, email, location, created_at FROM signups ORDER BY id DESC LIMIT $1', [limit]),
      ]);
      return { count: Number(total.rows[0].count), signups: recent.rows.map(toSignup) };
    });
  }

  add(email: string, location: string): Promise<Signup | null> {
    return this.run(async () => {
      const result = await this.pool.query<Row>(
        'INSERT INTO signups (email, location) VALUES ($1, $2) ON CONFLICT (email) DO NOTHING RETURNING id, email, location, created_at',
        [email, location],
      );
      return result.rows[0] ? toSignup(result.rows[0]) : null;
    });
  }

  async close(): Promise<void> {
    await this.pool.end();
  }
}

export function createStore(): Store {
  return process.env.PGHOST ? new PostgresStore() : new MemoryStore();
}
