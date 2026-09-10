# ADR-006: Multi-Tenancy dengan Row-Level Security

## Status
Accepted — 2026-09-10

## Context

Target SaaS 10.000 warung. Setiap warung adalah tenant yang harus:
- Data terisolasi
- Share infrastruktur (biaya efisien)
- Onboarding cepat

Pola:
- Database per tenant: isolasi maksimal, biaya tinggi
- Schema per tenant: isolasi baik, biaya menengah
- Row-level (shared tables): biaya rendah, butuh disiplin

Literatur:
- Cockroach Labs (2025). "You Shall Not Pass: Fine Grained Access Control with RLS."
- Permit.io (2025). "Fine-Grained Postgres Permissions."
- Back4App (2026). "Multi-Tenant Database Architecture."
- django-boundary (2026). PyPI.
- entwickler.de (2026). "PostgreSQL RLS."

## Decision

**Row-Level Security (RLS)** di PostgreSQL:
- Satu database untuk semua tenant
- Kolom `tenant_id` di setiap tabel
- RLS policy filter berdasarkan `tenant_id` dari JWT
- Role `app_user` dengan akses terbatas
- Audit log untuk akses sensitif

```sql
CREATE POLICY tenant_isolation ON products
  USING (tenant_id = current_setting('app.current_tenant')::uuid);
