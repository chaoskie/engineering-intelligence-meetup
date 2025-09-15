import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/app.ts';

test('GET /healthz', async () => {
  const app = createApp();
  const server = app.listen(0);
  const port = (server.address() as { port: number }).port;
  try {
    const res = await fetch(`http://127.0.0.1:${port}/healthz`);
    assert.equal(res.status, 200);
    assert.deepEqual(await res.json(), { ok: true, service: 'flowmetrics' });
  } finally {
    server.close();
  }
});
