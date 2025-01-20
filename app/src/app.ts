import express from 'express';
import { config } from './config.ts';
import { UsageClient } from './clients/usage-client.ts';
import { PaymentClient } from './clients/payment-client.ts';
import { BillingService } from './billing.ts';
import { billingRoutes } from './routes/billing.ts';
import { healthRoutes } from './routes/health.ts';

export interface AppDeps {
  fetchImpl?: typeof fetch;
}

export function createApp(deps: AppDeps = {}) {
  const usage = new UsageClient(deps.fetchImpl, config.usageBaseUrl);
  const payment = new PaymentClient(deps.fetchImpl, config.paymentBaseUrl);
  const billing = new BillingService(usage, payment);

  const app = express();
  app.use(express.json());
  app.use(healthRoutes());
  app.use('/billing', billingRoutes(billing));
  return app;
}
