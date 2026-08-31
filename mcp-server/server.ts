// Minimal MCP server (stdio, JSON-RPC 2.0) exposing two tools over the
// FlowMetrics wiki (a clone of the flowmetrics-wiki repo):
//   search(query, limit?)  keyword search over the markdown docs, returns snippets with paths
//   findings(pattern?, adr_ref?, category?)  structured filter and count over findings.json
// Wiki location: first argument, else WIKI_DIR, else ../../flowmetrics-wiki
// (a clone next to this repo). No dependencies.
// Protocol: https://modelcontextprotocol.io (2025-06-18).

import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createInterface } from 'node:readline';

const HERE = dirname(fileURLToPath(import.meta.url));
const WIKI = process.argv[2] ?? process.env.WIKI_DIR ?? join(HERE, '..', '..', 'flowmetrics-wiki');

interface Doc { path: string; title: string; text: string }

function loadDocs(dir: string): Doc[] {
  const out: Doc[] = [];
  const walk = (d: string) => {
    for (const name of readdirSync(d)) {
      const p = join(d, name);
      if (name === '.git') continue;
      if (statSync(p).isDirectory()) walk(p);
      else if (name.endsWith('.md')) {
        const text = readFileSync(p, 'utf8');
        const title = text.split('\n').find((l) => l.startsWith('# '))?.slice(2) ?? name;
        out.push({ path: relative(WIKI, p), title, text });
      }
    }
  };
  walk(dir);
  return out;
}

export function search(docs: Doc[], query: string, limit = 5) {
  const terms = query.toLowerCase().split(/\s+/).filter((t) => t.length > 1);
  const scored = docs.map((d) => {
    const lower = d.text.toLowerCase();
    let score = 0;
    for (const t of terms) {
      const hits = lower.split(t).length - 1;
      score += hits + (d.title.toLowerCase().includes(t) ? 5 : 0);
    }
    return { d, score };
  }).filter((s) => s.score > 0).sort((a, b) => b.score - a.score).slice(0, limit);

  return scored.map(({ d, score }) => {
    const lines = d.text.split('\n');
    const idx = lines.findIndex((l) => terms.some((t) => l.toLowerCase().includes(t)));
    const snippet = lines.slice(Math.max(0, idx - 1), idx + 4).join('\n');
    return { path: `flowmetrics-wiki/${d.path}`, title: d.title, score, snippet };
  });
}

interface Finding { id: string; date: string; service: string; category: string; root_cause: string; pattern: string; severity: string; adr_ref: string | null; incident: string | null }

export function findings(all: Finding[], filter: Partial<Pick<Finding, 'pattern' | 'adr_ref' | 'category'>>) {
  const rows = all.filter((f) =>
    (!filter.pattern || f.pattern === filter.pattern) &&
    (!filter.adr_ref || f.adr_ref === filter.adr_ref) &&
    (!filter.category || f.category === filter.category));
  const byPattern: Record<string, number> = {};
  for (const f of rows) byPattern[f.pattern] = (byPattern[f.pattern] ?? 0) + 1;
  return { count: rows.length, total: all.length, by_pattern: byPattern, findings: rows };
}

const TOOLS = [
  {
    name: 'search',
    description: 'Keyword search over the FlowMetrics wiki (ADRs, standards, runbooks, ways of working, meeting notes). Returns file paths, titles and snippets. Use it before changing code: the rules and their origin incidents live here. Check the status header of each document: superseded and stale documents are kept on purpose.',
    inputSchema: { type: 'object', properties: { query: { type: 'string' }, limit: { type: 'number' } }, required: ['query'] },
  },
  {
    name: 'findings',
    description: 'Filter and count structured post-mortem findings from the wiki findings.json by pattern, adr_ref or category. Use this for questions like "how many findings share pattern X" that keyword search cannot answer reliably.',
    inputSchema: { type: 'object', properties: { pattern: { type: 'string' }, adr_ref: { type: 'string' }, category: { type: 'string' } } },
  },
];

function main() {
  if (!statSync(WIKI, { throwIfNoEntry: false })?.isDirectory()) {
    process.stderr.write(`flowmetrics-wiki not found at ${WIKI}. Clone it next to this repo or pass the path as the first argument or WIKI_DIR.\n`);
    process.exit(1);
  }
  const docs = loadDocs(WIKI);
  const all: Finding[] = JSON.parse(readFileSync(join(WIKI, 'findings.json'), 'utf8')).findings;
  const send = (msg: unknown) => process.stdout.write(JSON.stringify(msg) + '\n');
  const text = (v: unknown) => ({ content: [{ type: 'text', text: JSON.stringify(v, null, 2) }] });

  createInterface({ input: process.stdin }).on('line', (line) => {
    if (!line.trim()) return;
    let req: { id?: unknown; method: string; params?: Record<string, unknown> };
    try { req = JSON.parse(line); } catch { return; }
    const reply = (result: unknown) => req.id !== undefined && send({ jsonrpc: '2.0', id: req.id, result });
    switch (req.method) {
      case 'initialize':
        return reply({ protocolVersion: '2025-06-18', capabilities: { tools: {} }, serverInfo: { name: 'flowmetrics-wiki', version: '0.2.0' } });
      case 'ping': return reply({});
      case 'tools/list': return reply({ tools: TOOLS });
      case 'tools/call': {
        const { name, arguments: args = {} } = req.params as { name: string; arguments?: Record<string, unknown> };
        if (name === 'search') return reply(text(search(docs, String(args.query ?? ''), Number(args.limit ?? 5))));
        if (name === 'findings') return reply(text(findings(all, args as Partial<Finding>)));
        return reply({ ...text({ error: `unknown tool ${name}` }), isError: true });
      }
      default:
        if (req.id !== undefined) send({ jsonrpc: '2.0', id: req.id, error: { code: -32601, message: `method not found: ${req.method}` } });
    }
  });
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();
