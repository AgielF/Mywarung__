# ADR-007: Deployment dengan GCP Cloud Run

## Status
Accepted — 2026-09-10

## Context

Butuh deployment yang:
- Murah (pay-per-use)
- Auto-scale
- Identik dengan lokal (Docker)
- Cocok untuk tim kecil

Literatur:
- ScienceDirect (2025). "Containerization in multi-cloud environment."
- Wiley (2026). "Scaling Smarter: Cloud-Native Software Engineering."
- Google Cloud Architecture Framework.

## Decision

- **Cloud Run** untuk semua service (API Gateway, Sync, AI)
- **Cloud SQL** PostgreSQL dengan RLS
- **GCS** untuk backup & model files
- **Pub/Sub** untuk async sync queue
- **Docker Compose** untuk lokal (identik dengan cloud)
- **Artifact Registry** untuk container images

## Consequences

**Positif:**
- Serverless, auto-scale to zero
- Murah (pay-per-use)
- Identik lokal & cloud
- Deployment cepat

**Negatif:**
- Cold start (mitigasi: min instances)
- Vendor lock-in GCP
- WebSocket di Cloud Run butuh konfigurasi khusus

**Mitigasi:**
- Min instance 1 untuk service kritikal
- Abstraksi container (tidak vendor-specific)
- Gunakan Cloud Run WebSocket support

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| GKE (Kubernetes) | Overkill untuk tim kecil |
| Compute Engine (VM) | Manual scaling, mahal |
| AWS Lambda | Cold start lebih buruk |
| Vercel/Netlify | Tidak cocok untuk backend Go |

## Referensi

- Google Cloud Architecture Framework.
- Cloud Run: cloud.google.com/run
- Cloud SQL: cloud.google.com/sql
