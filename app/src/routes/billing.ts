import { Router } from 'express';
import type { BillingService } from '../billing.ts';
import { log } from '../lib/logger.ts';

export function billingRoutes(billing: BillingService): Router {
  const r = Router();

  // POST /billing/runs { tenantId, periodId }
  r.post('/runs', async (req, res) => {
    const { tenantId, periodId } = req.body ?? {};
    if (typeof tenantId !== 'string' || typeof periodId !== 'string') {
      res.status(400).json({ error: 'tenantId and periodId are required strings' });
      return;
    }
    try {
      const result = await billing.runFor(tenantId, periodId);
      res.status(202).json(result);
    } catch (err) {
      log('error', 'billing run failed', { tenantId, periodId, err: String(err) });
      res.status(502).json({ error: 'billing run failed' });
    }
  });

  return r;
}
