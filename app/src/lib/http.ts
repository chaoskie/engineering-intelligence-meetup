// Thin wrapper over the built-in fetch; the single place for headers,
// timeouts and error mapping.

import { UpstreamError } from './retry.ts';

export interface HttpOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  headers?: Record<string, string>;
  body?: unknown;
  timeoutMs?: number;
  fetchImpl?: typeof fetch;
}

export async function httpJson<T>(url: string, opts: HttpOptions = {}): Promise<T> {
  const f = opts.fetchImpl ?? fetch;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), opts.timeoutMs ?? 5000);
  try {
    const res = await f(url, {
      method: opts.method ?? 'GET',
      headers: { 'content-type': 'application/json', ...(opts.headers ?? {}) },
      body: opts.body === undefined ? undefined : JSON.stringify(opts.body),
      signal: controller.signal,
    });
    if (!res.ok) throw new UpstreamError(res.status, `${opts.method ?? 'GET'} ${url} -> ${res.status}`);
    return (await res.json()) as T;
  } finally {
    clearTimeout(timer);
  }
}
