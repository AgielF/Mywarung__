# ADR-009: Observability dengan OpenTelemetry

## Status
Accepted — 2026-09-10

## Context

Bug di production sulit direproduksi tanpa observability. Butuh:
- Structured logging
- Metrics
- Traces
- Health check

Literatur:
- Microsoft Azure Well-Architected Framework (2026).
- Candido et al. "Log-based software monitoring." PeerJ CS.
- OpenTelemetry (CNCF).

## Decision

- **Structured logging** (JSON) dengan correlation ID
- **Metrics** via OpenTelemetry SDK
- **Traces** untuk sync & AI operations
- **Health check** endpoint `/health` dan `/ready`
- **Alerting** via Cloud Monitoring
- **Dashboard** via Cloud Logging + Grafana (opsional)

## Consequences

**Positif:**
- Debugging lebih mudah
- Monitoring proaktif
- Standar CNCF (portable)
- Integrasi dengan GCP native

**Negatif:**
- Overhead logging & tracing
- Biaya storage log
- Kompleksitas setup awal

**Mitigasi:**
- Sampling untuk traces (10% di production)
- Log level configurable per environment
- Retention policy 30 hari

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Custom logging | Tidak portable |
| Datadog/New Relic | Mahal untuk startup |
| Tanpa observability | Debugging buta |

## Referensi

- OpenTelemetry: opentelemetry.io
- Microsoft Azure (2026).
- Candido et al. PeerJ CS.
