// Usage collector client. Pulls metered usage per tenant.
// Uses the shared retry helper.

import { config } from '../config.ts';
import { httpJson } from '../lib/http.ts';
import { withRetry } from '../lib/retry.ts';
import { log } from '../lib/logger.ts';

export interface UsageRecord {
  tenantId: string;
  metric: string;
  quantity: number;
  periodStart: string;
  periodEnd: string;
}

export class UsageClient {
  private readonly fetchImpl?: typeof fetch;
  private readonly baseUrl: string;
  constructor(fetchImpl?: typeof fetch, baseUrl: string = config.usageBaseUrl) {
    this.fetchImpl = fetchImpl;
    this.baseUrl = baseUrl;
  }

  async fetchUsage(tenantId: string): Promise<UsageRecord[]> {
    return withRetry(
      () => httpJson<UsageRecord[]>(`${this.baseUrl}/tenants/${tenantId}/usage`, { fetchImpl: this.fetchImpl }),
      { attempts: 4, onRetry: (n, err) => log('warn', 'usage fetch retry', { tenantId, attempt: n, err: String(err) }) },
    );
  }
}
