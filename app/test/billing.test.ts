import { test } from 'node:test';
import assert from 'node:assert/strict';
import { priceUsage, BillingService } from '../src/billing.ts';
import { UsageClient } from '../src/clients/usage-client.ts';
import { PaymentClient } from '../src/clients/payment-client.ts';

process.env.PAYMENT_API_KEY = 'test-key';

function fakeFetch(handler: (url: string, init?: RequestInit) => unknown): typeof fetch {
  return (async (url: string | URL | Request, init?: RequestInit) => {
    const body = handler(String(url), init);
    return new Response(JSON.stringify(body), { status: 200, headers: { 'content-type': 'application/json' } });
  }) as typeof fetch;
}

test('priceUsage sums known metrics and ignores unknown ones', () => {
  const cents = priceUsage([
    { metric: 'api.calls', quantity: 100 },
    { metric: 'storage.gb', quantity: 2 },
    { metric: 'unknown', quantity: 99 },
  ]);
  assert.equal(cents, 140);
});

test('billing run charges the priced amount', async () => {
  const seen: { url: string; body: unknown }[] = [];
  const f = fakeFetch((url, init) => {
    seen.push({ url, body: init?.body ? JSON.parse(String(init.body)) : undefined });
    if (url.includes('/usage')) return [{ tenantId: 't1', metric: 'api.calls', quantity: 10, periodStart: '', periodEnd: '' }];
    return { chargeId: 'ch_1', status: 'succeeded' };
  });
  const svc = new BillingService(new UsageClient(f, 'http://usage'), new PaymentClient(f, 'http://pay'));
  const result = await svc.runFor('t1', '2026-08');
  assert.equal(result.chargeId, 'ch_1');
  const charge = seen.find((s) => s.url.endsWith('/v1/charges'));
  assert.deepEqual(charge?.body, { tenantId: 't1', amountCents: 10, currency: 'EUR', periodId: '2026-08' });
});
