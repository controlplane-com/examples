'use strict';

const STATUS_POLL_MS = 5000;
const CONTACTS_POLL_MS = 10000;

const PROVIDERS = { aws: 'AWS', gcp: 'GCP', azure: 'Azure', oci: 'OCI', linode: 'Akamai' };

const $ = (id) => document.getElementById(id);
let contacts = [];
let storage = 'memory';

function el(tag, props = {}, children = []) {
  const node = document.createElement(tag);
  Object.assign(node, props);
  for (const child of children) {
    node.append(child);
  }
  return node;
}

function providerLabel(provider) {
  return PROVIDERS[provider] || provider.toUpperCase();
}

async function api(path, options = {}) {
  const response = await fetch(path, { headers: { 'Content-Type': 'application/json' }, ...options });
  const body = response.status === 204 ? null : await response.json().catch(() => null);
  if (!response.ok) {
    throw new Error((body && body.error) || `The request failed with ${response.status}.`);
  }
  return body;
}

// Theme: the saved choice, else the system's; the toggle saves the other one.
function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  $('theme').setAttribute('aria-label', theme === 'dark' ? 'Switch to light theme' : 'Switch to dark theme');
}

$('theme').addEventListener('click', () => {
  const next = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
  localStorage.setItem('phonebook-theme', next);
  applyTheme(next);
});

applyTheme(document.documentElement.dataset.theme);

function renderServed(status) {
  const local = status.provider === 'local';
  const cloud = local ? 'this computer' : providerLabel(status.provider);
  $('served-place').textContent = status.place ? `${cloud} · ${status.place}` : cloud;
  $('served-location').textContent = local ? '' : status.location;
  $('locations-title').textContent = status.gvc ? `Locations of ${status.gvc}` : 'Locations';

  const global = $('global-endpoint');
  global.hidden = !status.globalEndpoint;
  global.href = status.globalEndpoint ?? '#';

  $('footer-workload').textContent = [status.workload, `version ${status.version}`, status.image]
    .filter(Boolean)
    .join(' · ');
}

const OPEN_ICON = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M7 17 17 7M8 7h9v9" /></svg>';

function locationRow(item) {
  const main = el('span', { className: 'main' }, [
    el('span', { className: `dot ${item.healthy ? 'good' : 'bad'}` }),
    el('span', { className: 'name', textContent: item.name }),
  ]);

  if (item.current) {
    return el('li', { className: 'current' }, [main, el('span', { className: 'state', textContent: 'Serving you' })]);
  }

  if (!item.healthy || !item.endpoint) {
    const state = item.healthy ? 'Healthy' : 'Unavailable';
    return el('li', { className: item.healthy ? '' : 'down' }, [main, el('span', { className: 'state', textContent: state })]);
  }

  const link = el('a', { href: item.endpoint, target: '_blank', rel: 'noopener' }, [
    main,
    el('span', { className: 'state' }, ['Healthy', el('span', { className: 'open', innerHTML: OPEN_ICON })]),
  ]);
  link.setAttribute('aria-label', `${item.name}, healthy. Open the app served from ${item.name} in a new tab`);
  return el('li', { className: 'link' }, [link]);
}

function renderLocations(view) {
  $('locations').replaceChildren(...view.items.map(locationRow));

  const notes = {
    local: 'Running outside Control Plane.',
    'no-access': 'Only this location is listed: grant the workload identity view on its GVC and workload to see them all.',
    unavailable: 'The Control Plane API did not answer, so only this location is listed.',
  };
  const note = $('locations-note');
  note.hidden = view.all;
  note.textContent = view.all ? '' : notes[view.reason];
}

function renderDatabase(database) {
  const section = $('database');
  storage = database.kind;

  if (database.kind === 'memory') {
    section.className = 'db idle';
    $('database-title').textContent = 'No database connected';
    $('database-detail').textContent = 'Contacts are kept in memory on the replica that stored them.';
    return;
  }

  section.className = database.connected ? 'db good' : 'db bad';
  $('database-title').textContent = database.connected ? 'PostgreSQL connected' : 'PostgreSQL unreachable';
  $('database-detail').textContent = database.connected ? `Contacts are saved in ${database.host}.` : database.error;
}

async function refreshStatus() {
  try {
    const status = await api('/api/status');
    renderServed(status);
    renderLocations(status.locations);
    renderDatabase(status.database);
  } catch {
    // the next poll tries again; the page keeps what it last showed
  }
}

function initials(name) {
  const parts = name.split(' ').filter(Boolean);
  return ((parts[0] || '')[0] + ((parts[1] || '')[0] || '')).toUpperCase();
}

const REMOVE_ICON =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14" /></svg>';

function renderContacts() {
  const query = $('search').value.trim().toLowerCase();
  const shown = contacts.filter(
    (contact) => !query || contact.name.toLowerCase().includes(query) || contact.phone.includes(query),
  );

  $('contacts-count').textContent = contacts.length > 0 ? `· ${contacts.length}` : '';
  $('contacts').replaceChildren(
    ...shown.map((contact) => {
      const remove = el('button', { type: 'button', className: 'remove', innerHTML: REMOVE_ICON });
      remove.setAttribute('aria-label', `Delete ${contact.name}`);
      remove.addEventListener('click', () => removeContact(contact.id));

      const avatar = el('span', { className: 'avatar', textContent: initials(contact.name) });
      avatar.setAttribute('aria-hidden', 'true');

      return el('li', {}, [
        avatar,
        el('div', { className: 'who' }, [
          el('p', { className: 'name', textContent: contact.name }),
          el('p', { className: 'meta' }, [
            el('a', { href: `tel:${contact.phone.replace(/[^\d+]/g, '')}`, textContent: contact.phone }),
            ` · saved in ${contact.location}`,
          ]),
        ]),
        remove,
      ]);
    }),
  );

  const empty = $('empty');
  empty.hidden = shown.length > 0;
  empty.textContent = contacts.length === 0 ? 'No contacts yet.' : 'No contacts match your search.';
}

async function refreshContacts() {
  try {
    contacts = (await api('/api/contacts')).contacts;
    renderContacts();
  } catch (error) {
    if (storage === 'postgres') {
      contacts = [];
      renderContacts();
    }
  }
}

async function removeContact(id) {
  try {
    await api(`/api/contacts/${id}`, { method: 'DELETE' });
  } catch {
    // another replica may have stored it; the refresh below shows what this one has
  }
  await refreshContacts();
}

$('add').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  const error = $('add-error');
  const submit = form.querySelector('button');
  error.hidden = true;
  submit.disabled = true;

  try {
    await api('/api/contacts', {
      method: 'POST',
      body: JSON.stringify({ name: form.elements.name.value, phone: form.elements.phone.value }),
    });
    form.reset();
    form.elements.name.focus();
    await refreshContacts();
  } catch (cause) {
    error.textContent = cause.message;
    error.hidden = false;
  } finally {
    submit.disabled = false;
  }
});

$('search').addEventListener('input', renderContacts);

refreshStatus();
refreshContacts();
setInterval(refreshStatus, STATUS_POLL_MS);
setInterval(refreshContacts, CONTACTS_POLL_MS);
