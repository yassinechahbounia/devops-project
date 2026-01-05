// src/app/config/env.service.ts
export class EnvService {
  public apiUrl = (window as any).__env?.apiUrl || 'http://localhost:8080';
}