import type { Metadata } from 'next';
import { site } from '../site.config';
import { runtime } from '../lib/runtime';
import './globals.css';

export const metadata: Metadata = {
  title: `${site.name}: ${site.tagline}`,
  description: site.description,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  const { location, workload, version } = runtime();
  const initial = site.name.trim().charAt(0).toUpperCase();

  return (
    <html lang="en">
      <body>
        <header className="header">
          <div className="container header-inner">
            <div className="header-left">
              <a href="#top" className="brand">
                <span className="product-mark" aria-hidden="true">
                  {initial}
                </span>
                <span>{site.name}</span>
              </a>
              <a className="provided-by" href="https://controlplane.com" target="_blank" rel="noreferrer">
                <span>Provided by</span>
                <img src="/control-plane-mark.svg" alt="" height={16} width={14} />
                <strong>Control Plane</strong>
              </a>
            </div>
            <nav className="nav">
              <a href="#features">Features</a>
              <a href="#waitlist">Waitlist</a>
            </nav>
          </div>
        </header>

        <main className="container main">{children}</main>

        <footer className="footer">
          <div className="container footer-inner">
            <span className="served">
              {location ? (
                <>
                  Served from <code>{location}</code> by workload <code>{workload}</code>, version <code>{version}</code>
                </>
              ) : (
                <>Running locally. Deploy it to Control Plane to see which location serves each request.</>
              )}
            </span>
          </div>
        </footer>
      </body>
    </html>
  );
}
