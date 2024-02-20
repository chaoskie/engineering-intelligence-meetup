// Runtime configuration. Only non-secret values live here.
// Secrets go through lib/secrets.ts. Do not add API keys to this file.

export const config = {
  port: Number(process.env.PORT ?? 3000),
  serviceName: 'flowmetrics',
  paymentBaseUrl: process.env.PAYMENT_BASE_URL ?? 'http://localhost:3999',
  usageBaseUrl: process.env.USAGE_BASE_URL ?? 'http://localhost:3998',
} as const;
