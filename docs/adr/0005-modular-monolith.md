# ADR-005: Modular Monolith, bukan Microservices

## Status
Accepted — 2026-09-10

## Context

Proyek dikembangkan 1 orang dengan target SaaS. Keputusan harus mempertimbangkan:
- Kompleksitas operasional
- Waktu development
- Biaya infrastruktur
- Kemampuan scaling

Pilihan: Monolith, Microservices, Modular Monolith.

Literatur:
- Su, R., & Li, X. (2024). "Modular Monolith." SATrends '24, ACM.
- Krzysztoń & Łatwiński (2025). Journal of Computer Sciences Institute, Vol. 34.
- SLR (2025). "Modular Monolith Architecture in Cloud Environments." Semantic Scholar.
- Fowler, M. (2014). "Microservices."

## Decision

**Modular Monolith** dengan:
- Satu codebase, satu deployment unit
- Boundary modul jelas (DDD)
- Komunikasi antar-modul via interface
- Database tunggal dengan schema terpisah

**Modul utama:**
1. Sales — transaksi, struk
2. Inventory — produk, stok
3. Customer — pelanggan, kasbon
4. Reporting — laporan, analytics
5. AI — chatbot, computer vision
6. Sync — sinkronisasi CRDT
7. Auth — autentikasi, multi-tenancy

## Consequences

**Positif:**
- Development cepat
- Debugging mudah (single process)
- Testing sederhana
- Biaya infrastruktur rendah
- Bisa di-refactor ke microservices nanti

**Negatif:**
- Scaling vertical dulu
- Coupling antar-modul bisa terjadi
- Build time meningkat seiring waktu
- Single point of failure

**Mitigasi:**
- Disiplin boundary (code review, ArchUnit)
- Modular testing (test per modul)
- CI/CD dengan incremental build
- Blue-green deployment

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Microservices | Overkill untuk tim 1 orang |
| Monolith tanpa modular | Sulit di-maintain |
| Serverless functions | Cold start, vendor lock-in |
| SOA | Terlalu enterprise |

## Referensi

- Su, R., & Li, X. (2024). SATrends '24, ACM.
- Krzysztoń & Łatwiński (2025). Vol. 34.
- Fowler, M. (2014). martinfowler.com
- Evans, E. (2003). Domain-Driven Design.
