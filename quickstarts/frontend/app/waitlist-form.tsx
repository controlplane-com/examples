'use client';

import { useActionState } from 'react';
import { join, type JoinState } from './actions';

export function WaitlistForm({ disabled }: { disabled: boolean }) {
  const [state, action, pending] = useActionState<JoinState, FormData>(join, null);
  const inactive = disabled || pending;

  return (
    <form action={action} className="waitlist-form">
      <div className="waitlist-row">
        <label className="visually-hidden" htmlFor="email">
          Email address
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          placeholder="you@company.com"
          required
          disabled={inactive}
        />
        <button type="submit" disabled={inactive}>
          {pending ? 'Joining' : 'Join the waitlist'}
        </button>
      </div>
      {state && (
        <p role="status" className={state.ok ? 'form-message form-ok' : 'form-message form-error'}>
          {state.message}
        </p>
      )}
    </form>
  );
}
