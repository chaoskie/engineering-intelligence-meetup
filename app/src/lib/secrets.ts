// Secrets helper: no secrets in config files or source.
// Reads from the environment today; the production build swaps this module
// for the Vault-backed implementation. Callers never read process.env directly.

const cache = new Map<string, string>();

export function getSecret(name: string): string {
  const cached = cache.get(name);
  if (cached !== undefined) return cached;
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing secret ${name}. See app/.env.example`);
  }
  cache.set(name, value);
  return value;
}

export function clearSecretCache(): void {
  cache.clear();
}
