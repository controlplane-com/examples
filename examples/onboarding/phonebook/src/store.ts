import pg from 'pg';

export type Contact = {
  id: number;
  name: string;
  phone: string;
  location: string;
  createdAt: string;
};

export type DatabaseStatus =
  | { kind: 'memory' }
  | { kind: 'postgres'; connected: true; host: string }
  | { kind: 'postgres'; connected: false; host: string; error: string };

export interface Store {
  readonly kind: 'memory' | 'postgres';
  list(limit: number): Promise<Contact[]>;
  add(name: string, phone: string, location: string): Promise<Contact>;
  // Resolves to false when there was no such contact.
  remove(id: number): Promise<boolean>;
  status(): Promise<DatabaseStatus>;
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
  private readonly contacts = new Map<number, Contact>();
  private nextId = 1;

  async list(limit: number): Promise<Contact[]> {
    return [...this.contacts.values()].sort((a, b) => a.name.localeCompare(b.name)).slice(0, limit);
  }

  async add(name: string, phone: string, location: string): Promise<Contact> {
    const contact = { id: this.nextId++, name, phone, location, createdAt: new Date().toISOString() };
    this.contacts.set(contact.id, contact);
    return contact;
  }

  async remove(id: number): Promise<boolean> {
    return this.contacts.delete(id);
  }

  async status(): Promise<DatabaseStatus> {
    return { kind: 'memory' };
  }

  async close(): Promise<void> {}
}

type Row = { id: number; name: string; phone: string; location: string; created_at: Date };

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
  )`;

const STATUS_TTL_MS = 5_000;

function toContact(row: Row): Contact {
  return { id: row.id, name: row.name, phone: row.phone, location: row.location, createdAt: row.created_at.toISOString() };
}

// The pool reads PGHOST, PGPORT, PGUSER, PGPASSWORD, and PGDATABASE from the environment.
class PostgresStore implements Store {
  readonly kind = 'postgres' as const;
  private readonly pool = new pg.Pool({ connectionTimeoutMillis: 3_000 });
  private readonly host = process.env.PGHOST ?? '';
  private schemaReady: Promise<void> | null = null;
  private lastStatus: { at: number; value: DatabaseStatus } | null = null;

  constructor() {
    // An idle client that loses its connection must not take the process down.
    this.pool.on('error', () => {});
  }

  // Creates the table on first use; a failure is retried on the next request.
  private ready(): Promise<void> {
    this.schemaReady ??= this.pool
      .query(SCHEMA)
      .then(() => undefined)
      .catch((cause: unknown) => {
        this.schemaReady = null;
        throw new DatabaseUnavailable(cause);
      });
    return this.schemaReady;
  }

  private async run<T>(work: () => Promise<T>): Promise<T> {
    await this.ready();
    try {
      return await work();
    } catch (cause) {
      throw new DatabaseUnavailable(cause);
    }
  }

  list(limit: number): Promise<Contact[]> {
    return this.run(async () => {
      const result = await this.pool.query<Row>('SELECT * FROM contacts ORDER BY lower(name), id LIMIT $1', [limit]);
      return result.rows.map(toContact);
    });
  }

  add(name: string, phone: string, location: string): Promise<Contact> {
    return this.run(async () => {
      const result = await this.pool.query<Row>(
        'INSERT INTO contacts (name, phone, location) VALUES ($1, $2, $3) RETURNING *',
        [name, phone, location],
      );
      return toContact(result.rows[0]!);
    });
  }

  remove(id: number): Promise<boolean> {
    return this.run(async () => {
      const result = await this.pool.query('DELETE FROM contacts WHERE id = $1', [id]);
      return (result.rowCount ?? 0) > 0;
    });
  }

  async status(): Promise<DatabaseStatus> {
    if (this.lastStatus && Date.now() - this.lastStatus.at < STATUS_TTL_MS) {
      return this.lastStatus.value;
    }
    let value: DatabaseStatus;
    try {
      await this.ready();
      await this.pool.query('SELECT 1');
      value = { kind: 'postgres', connected: true, host: this.host };
    } catch (cause) {
      value = { kind: 'postgres', connected: false, host: this.host, error: reasonOf(cause) };
    }
    this.lastStatus = { at: Date.now(), value };
    return value;
  }

  async close(): Promise<void> {
    await this.pool.end();
  }
}

export function createStore(): Store {
  return process.env.PGHOST ? new PostgresStore() : new MemoryStore();
}
