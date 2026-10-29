import { site } from '../site.config';
import { getWaitlist } from '../lib/api';
import { featureIcons } from './icons';
import { WaitlistForm } from './waitlist-form';

// Render on every request so the footer and the waitlist reflect the live state.
export const dynamic = 'force-dynamic';

function relativeTime(iso: string) {
  const seconds = Math.max(0, Math.round((Date.now() - new Date(iso).getTime()) / 1000));
  if (seconds < 60) return 'just now';
  const minutes = Math.round(seconds / 60);
  if (minutes < 60) return `${minutes} min ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours} h ago`;
  return new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

export default async function Home() {
  const waitlist = await getWaitlist();
  const open = waitlist.status === 'ok';
  const count = waitlist.status === 'ok' ? waitlist.data.count : 0;

  return (
    <>
      <section className="hero" id="top">
        <span className="eyebrow">Launching soon</span>
        <h1>{site.tagline}</h1>
        <p className="lede">{site.description}</p>

        <WaitlistForm disabled={!open} />

        <p className={`hero-note${waitlist.status === 'unreachable' || waitlist.status === 'rejected' ? ' hero-note-error' : ''}`}>
          {waitlist.status === 'unconfigured' && (
            <>
              The waitlist opens once an API is connected. Set <code>API_URL</code> on this workload.
            </>
          )}
          {waitlist.status === 'unreachable' && (
            <>
              Could not reach the API at <code>{waitlist.url}</code>: {waitlist.reason}.
            </>
          )}
          {waitlist.status === 'rejected' && (
            <>
              The API at <code>{waitlist.url}</code> answered HTTP {waitlist.httpStatus}: {waitlist.message}
            </>
          )}
          {open && count === 0 && <>Be the first on the list.</>}
          {open && count > 0 && (
            <>
              <strong>{count}</strong> {count === 1 ? 'person is' : 'people are'} already waiting.
            </>
          )}
        </p>
      </section>

      <section className="features" id="features">
        {site.features.map((feature, index) => (
          <article className="feature" key={feature.title}>
            <span className="feature-icon">{featureIcons[index % featureIcons.length]}</span>
            <h2>{feature.title}</h2>
            <p>{feature.text}</p>
          </article>
        ))}
      </section>

      <section className="signups" id="waitlist">
        <div className="section-head">
          <h2>Recent signups</h2>
          {waitlist.status === 'ok' && (
            <span className={`badge badge-${waitlist.data.storage}`}>
              <span className="dot" />
              {waitlist.data.storage === 'postgres' ? 'Stored in PostgreSQL' : 'Stored in memory'} by{' '}
              <code>{waitlist.data.workload}</code> in <code>{waitlist.data.location}</code>
            </span>
          )}
        </div>

        {!open && <p className="empty">Signups appear here once the API answers.</p>}
        {open && waitlist.data.signups.length === 0 && <p className="empty">No signups yet.</p>}
        {open && waitlist.data.signups.length > 0 && (
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Stored in</th>
                  <th>When</th>
                </tr>
              </thead>
              <tbody>
                {waitlist.data.signups.map((signup) => (
                  <tr key={signup.id}>
                    <td>{signup.email}</td>
                    <td>
                      <code>{signup.location}</code>
                    </td>
                    <td className="muted">{relativeTime(signup.createdAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </>
  );
}
