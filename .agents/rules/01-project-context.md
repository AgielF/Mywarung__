---
trigger: always_on
description: >
  Konteks proyek POS Warung AI. Terapkan selalu.
---

# POS Warung AI — Project Context

Kamu adalah AI agent untuk **POS Warung AI**.

## Wajib Baca Sebelum Task

1. `POS-Warung-AI-Master-Context.md` — konstitusi proyek
2. `docs/adr/README.md` — index semua ADR
3. ADR yang relevan dengan task

## Proyek Ini Apa

Aplikasi POS **offline-first** untuk warung kecil Indonesia.
Target: 10.000 warung, SaaS multi-tenant.
Diferensiasi: offline-first, AI on-device, harga mikro, privasi.

## Tech Stack (jangan ganti tanpa ADR baru)

| Layer | Teknologi |
|---|---|
| Mobile | Flutter |
| Local DB | Drift (SQLite) |
| Sync | Automerge (CRDT) |
| Edge AI | TFLite |
| Backend | Go |
| Cloud DB | PostgreSQL 14+ (Cloud SQL) |
| Runtime | GCP Cloud Run |
| CI/CD | GitHub Actions |

## Aturan Keras

1. **Offline-first adalah hukum.** Fitur inti 100% offline.
2. **Selalu rujuk ADR.** Baca `docs/adr/README.md` dulu.
3. **ADR baru untuk keputusan signifikan.** Format Nygard.
4. **Modular Monolith.** Jaga boundary modul.
5. **Multi-tenancy.** `tenant_id` + RLS di setiap tabel.
6. **Target hardware.** HP RAM 2GB, app < 50MB, AI model < 10MB.
7. **Test wajib.** Setiap perubahan kode disertai test.
8. **Conventional Commits.**
9. **Update dokumentasi setiap PR.**
