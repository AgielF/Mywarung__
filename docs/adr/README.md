# Architecture Decision Records (ADR)

Dokumen ini mencatat semua keputusan arsitektur signifikan untuk proyek POS Warung AI.

Format: [Michael Nygard (2011)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
Standar: [ISO/IEC/IEEE 42010:2011](https://www.iso.org/standard/50508.html)

## Daftar ADR

### Arsitektur Inti

| # | Judul | Status | Tanggal |
|---|---|---|---|
| [001](0001-offline-first.md) | Offline-First dengan Local DB | Accepted | 2026-09-10 |
| [002](0002-crdt-sync.md) | CRDT untuk Sync | Accepted | 2026-09-10 |
| [003](0003-on-device-ai.md) | On-Device AI untuk CV | Accepted | 2026-09-10 |
| [004](0004-hybrid-chatbot.md) | Hybrid Chatbot | Accepted | 2026-09-10 |
| [005](0005-modular-monolith.md) | Modular Monolith | Accepted | 2026-09-10 |
| [006](0006-multi-tenancy-rls.md) | Multi-Tenancy RLS | Accepted | 2026-09-10 |

### Infrastruktur

| # | Judul | Status | Tanggal |
|---|---|---|---|
| [007](0007-deployment-gcp.md) | Deployment GCP Cloud Run | Accepted | 2026-09-10 |
| [008](0008-security.md) | JWT + SQLCipher + RLS | Accepted | 2026-09-10 |
| [009](0009-observability.md) | OpenTelemetry | Accepted | 2026-09-10 |
| [010](0010-documentation.md) | arc42 + C4 + ADR | Accepted | 2026-09-10 |

### Tech Stack

| # | Judul | Status | Tanggal |
|---|---|---|---|
| [011](0011-mobile-framework.md) | Mobile Framework — Flutter | Accepted | 2026-09-10 |
| [012](0012-backend-language.md) | Backend Language — Go | Accepted | 2026-09-10 |
| [013](0013-crdt-library.md) | CRDT Library — Automerge | Accepted | 2026-09-10 |
| [014](0014-local-db.md) | Local DB — Drift | Accepted | 2026-09-10 |
| [015](0015-chatbot-nlu.md) | Chatbot NLU — Custom + Rasa | Accepted | 2026-09-10 |

## Cara Menambah ADR Baru

1. Copy `template.md`
2. Rename: `XXXX-judul-singkat.md` (XXXX = nomor berikutnya)
3. Isi Context, Decision, Consequences, Alternatif
4. Update tabel di README ini
5. Commit dengan pesan: `docs(adr): add ADR-XXXX [judul]`
