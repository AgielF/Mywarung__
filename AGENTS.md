# AGENTS.md — Instruksi Universal untuk AI Agent

Dokumen ini dibaca oleh AI agent apa pun (Antigravity, Roo Code, Cline, Cursor, Copilot Workspace, Aider).

## Konstitusi Proyek

WAJIB BACA DULU: POS-Warung-AI-Master-Context.md

Dokumen itu adalah sumber kebenaran tunggal untuk:

- Tujuan proyek
- Tech stack
- Architectural drivers (FR, QA, Constraints)
- 15 ADR
- C4 Model
- Roadmap
- Referensi literatur

## Ringkasan Cepat

| Aspek | Nilai |
|---|---|
| Proyek | POS Warung AI |
| Target | Warung kecil Indonesia - SaaS 10.000 warung |
| Diferensiasi | Offline-first, AI on-device, harga mikro, privasi |
| Mobile | Flutter |
| Backend | Go |
| Local DB | Drift (SQLite) |
| Sync | Automerge (CRDT) |
| Edge AI | TFLite |
| Cloud | GCP Cloud Run + Cloud SQL + GCS |
| CI/CD | GitHub Actions |

## Aturan Keras

1. Offline-first adalah hukum. Fitur inti 100% offline.
2. Selalu rujuk ADR. Baca docs/adr/README.md dulu.
3. ADR baru untuk keputusan signifikan. Format Nygard.
4. Modular Monolith. Jaga boundary modul.
5. Multi-tenancy. tenant_id + RLS di setiap tabel.
6. Target hardware. HP RAM 2GB, app < 50MB, AI model < 10MB.
7. Test wajib. Setiap perubahan kode disertai test.
8. Conventional Commits.
9. Update dokumentasi setiap PR.

## Struktur Konfigurasi AI

| Folder/File | Untuk | Fungsi |
|---|---|---|
| AGENTS.md | Universal | Instruksi lintas-alat |
| .agents/agents/ | Antigravity | Custom agent (pos-architect, pos-coder) |
| .agents/rules/ | Antigravity | Rules (always_on) |
| .roomodes | Roo Code | Custom mode |
| .clinerules/ | Cline | Rules |

## Setelah Setiap Task

- Update ADR jika ada keputusan baru
- Update docs/adr/README.md
- Update C4 diagram jika ada container/component baru
- Update roadmap jika ada perubahan scope
- Verifikasi tidak ada regresi offline-first
- Verifikasi tidak ada kebocoran tenant data

## File Penting

| File | Fungsi |
|---|---|
| POS-Warung-AI-Master-Context.md | Konstitusi proyek |
| docs/adr/README.md | Index ADR |
| docs/adr/template.md | Template ADR baru |
| docs/architecture/arc42.md | Dokumentasi arsitektur |
| README.md | Dokumentasi untuk manusia |
| .agents/agents/pos-architect.md | Custom agent arsitek |
| .agents/agents/pos-coder.md | Custom agent coder |
| .agents/rules/01-project-context.md | Rule: konteks proyek |
| .agents/rules/02-architecture-rules.md | Rule: arsitektur |
| .agents/rules/03-adr-rules.md | Rule: ADR |
