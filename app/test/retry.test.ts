import { test } from 'node:test';
import assert from 'node:assert/strict';
import { withRetry, RetryError, UpstreamError } from '../src/lib/retry.ts';

const noSleep = async () => {};

test('withRetry returns on first success', async () => {
  const v = await withRetry(async () => 42, { sleep: noSleep });
  assert.equal(v, 42);
});

test('withRetry retries transient errors then succeeds', async () => {
  let calls = 0;
  const v = await withRetry(async () => {
    calls++;
    if (calls < 3) throw new UpstreamError(503, 'busy');
    return 'ok';
  }, { sleep: noSleep });
  assert.equal(v, 'ok');
  assert.equal(calls, 3);
});

test('withRetry does not retry non-retryable errors', async () => {
  let calls = 0;
  await assert.rejects(
    withRetry(async () => { calls++; throw new UpstreamError(400, 'bad'); }, { sleep: noSleep }),
    (e: unknown) => e instanceof RetryError && e.attempts === 3,
  );
  assert.equal(calls, 1);
});
