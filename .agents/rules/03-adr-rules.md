---
trigger: always_on
description: >
  Aturan pembuatan ADR untuk POS Warung AI. Terapkan selalu.
---

# Aturan ADR (Architecture Decision Record)

## Kapan Buat ADR Baru

Buat ADR baru jika:

- Menambah/mengganti library atau framework
- Mengubah boundary modul
- Mengubah strategi sync, auth, atau data
- Mengubah deployment atau infrastruktur
- Mengubah tech stack

## Format Nygard

```markdown
# ADR-XXX: [Judul]

## Status
[Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
Tanggal: YYYY-MM-DD

## Context
[masalah + literatur]

## Decision
[keputusan konkret]

## Consequences
Positif / Negatif / Mitigasi

## Alternatif yang Ditolak
[tabel]

## Referensi
[paper/buku/standar]
