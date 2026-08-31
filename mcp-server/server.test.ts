import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));

function rpc(lines: object[]): Promise<object[]> {
  return new Promise((resolve, reject) => {
    const p = spawn(process.execPath, [join(HERE, 'server.ts')], { stdio: ['pipe', 'pipe', 'inherit'] });
    let out = '';
    p.stdout.on('data', (d) => { out += d; });
    p.on('close', () => resolve(out.trim().split('\n').map((l) => JSON.parse(l))));
    p.on('error', reject);
    for (const l of lines) p.stdin.write(JSON.stringify(l) + '\n');
    p.stdin.end();
  });
}

test('initialize, list tools, search and count findings', async () => {
  const res = await rpc([
    { jsonrpc: '2.0', id: 1, method: 'initialize', params: {} },
    { jsonrpc: '2.0', id: 2, method: 'tools/list' },
    { jsonrpc: '2.0', id: 3, method: 'tools/call', params: { name: 'search', arguments: { query: 'idempotency key retry' } } },
    { jsonrpc: '2.0', id: 4, method: 'tools/call', params: { name: 'findings', arguments: { pattern: 'config-drift' } } },
  ]) as any[];
  assert.equal(res[0].result.serverInfo.name, 'flowmetrics-wiki');
  assert.deepEqual(res[1].result.tools.map((t: any) => t.name), ['search', 'findings']);
  const hits = JSON.parse(res[2].result.content[0].text);
  assert.ok(hits[0].path.includes('ADR-007'), `expected ADR-007 first, got ${hits[0].path}`);
  const f = JSON.parse(res[3].result.content[0].text);
  assert.equal(f.count, 8);
});
