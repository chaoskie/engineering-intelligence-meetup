import { createApp } from './app.ts';
import { config } from './config.ts';
import { log } from './lib/logger.ts';

const app = createApp();
app.listen(config.port, () => log('info', 'listening', { port: config.port }));
