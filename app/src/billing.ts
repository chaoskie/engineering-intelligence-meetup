// Billing run: turn usage into a charge for one tenant and period.

import type { UsageClient } from './clients/usage-client.ts';
import type { PaymentClient, ChargeResult } from './clients/payment-client.ts';
import { log } from './lib/logger.ts';

const PRICE_CENTS: Record<string, number> = { 'api.calls': 1, 'storage.gb': 20, 'events.ingested': 2 };

export function priceUsage(records: { metric: string; quantity: number }[]): number {
  return records.reduce((sum, r) => sum + (PRICE_CENTS[r.metric] ?? 0) * r.quantity, 0);
}

export class BillingService {
  private readonly usage: UsageClient;
  private readonly payment: PaymentClient;
  constructor(usage: UsageClient, payment: PaymentClient) {
    this.usage = usage;
    this.payment = payment;
  }

  async runFor(tenantId: string, periodId: string): Promise<ChargeResult> {
    const records = await this.usage.fetchUsage(tenantId);
    const amountCents = priceUsage(records);
    log('info', 'billing run', { tenantId, periodId, amountCents, records: records.length });
    return this.payment.charge({ tenantId, amountCents, currency: 'EUR', periodId });
  }
}
