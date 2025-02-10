// Payment provider client. Charges a tenant for a billing period.

import { config } from '../config.ts';
import { httpJson } from '../lib/http.ts';
import { getSecret } from '../lib/secrets.ts';

export interface ChargeRequest {
  tenantId: string;
  amountCents: number;
  currency: 'EUR' | 'USD';
  periodId: string;
}

export interface ChargeResult {
  chargeId: string;
  status: 'succeeded' | 'pending' | 'failed';
}

export class PaymentClient {
  private readonly fetchImpl?: typeof fetch;
  private readonly baseUrl: string;
  constructor(fetchImpl?: typeof fetch, baseUrl: string = config.paymentBaseUrl) {
    this.fetchImpl = fetchImpl;
    this.baseUrl = baseUrl;
  }

  async charge(req: ChargeRequest): Promise<ChargeResult> {
    return httpJson<ChargeResult>(`${this.baseUrl}/v1/charges`, {
      method: 'POST',
      headers: { authorization: `Bearer ${getSecret('PAYMENT_API_KEY')}` },
      body: req,
      fetchImpl: this.fetchImpl,
    });
  }
}
