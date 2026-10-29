'use server';

import { revalidatePath } from 'next/cache';
import { joinWaitlist } from '../lib/api';

export type JoinState = { ok: boolean; message: string } | null;

export async function join(_previous: JoinState, formData: FormData): Promise<JoinState> {
  const email = String(formData.get('email') ?? '').trim();
  const result = await joinWaitlist(email);

  switch (result.status) {
    case 'ok':
      revalidatePath('/');
      return { ok: true, message: `You're on the list as ${result.data.signup.email}.` };
    case 'rejected':
      return { ok: false, message: result.message };
    case 'unreachable':
      return { ok: false, message: `Could not reach the API at ${result.url}: ${result.reason}.` };
    case 'unconfigured':
      return { ok: false, message: 'No API is connected to this site yet.' };
  }
}
