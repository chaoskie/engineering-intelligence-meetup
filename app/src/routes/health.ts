import { Router } from 'express';
import { config } from '../config.ts';

export function healthRoutes(): Router {
  const r = Router();
  r.get('/healthz', (_req, res) => res.json({ ok: true, service: config.serviceName }));
  return r;
}
