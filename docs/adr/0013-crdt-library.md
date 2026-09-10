# ADR-013: CRDT Library — Automerge

## Status
Accepted — 2026-09-10

## Context

Butuh CRDT library yang:
- Mendukung Dart (Flutter) dan Go (backend)
- Stabil, terdokumentasi, aktif dikembangkan
- Mendukung JSON-like data (produk, transaksi, kasbon)
- Ukuran binary kecil untuk mobile

Pilihan: Automerge, Yjs, custom implementation.

## Decision

Gunakan **Automerge** dengan alasan:

| Aspek | Automerge | Yjs | Custom |
|---|---|---|---|
| Dart support | `automerge` | Tidak ada | — |
| Go support | `automerge-go` | Terbatas | — |
| JSON-like data | Native | Perlu wrapper | — |
| Binary size | ~1MB | ~500KB | Minimal |
| Maturity | 10+ tahun | 8+ tahun | Risk |
| Dokumentasi | Lengkap | Lengkap | Tidak ada |

## Consequences

**Positif:**
- Satu library untuk mobile + backend
- JSON-like data cocok untuk domain POS
- Format binary efisien untuk sync
- Aktif dikembangkan (Ink & Switch)

**Negatif:**
- Binary size ~1MB (bisa dikurangi dengan tree-shaking)
- Perlu learning curve untuk CRDT concepts
- Tidak semua operasi bisnis bisa dimodelkan

**Mitigasi:**
- Gunakan `automerge` Dart untuk mobile
- `automerge-go` untuk backend sync service
- Dokumentasikan CRDT types di ADR-002

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Yjs | Tidak ada Dart support resmi |
| Custom CRDT | Risk tinggi, butuh riset mendalam |
| Operational Transformation | Butuh server terpusat |

## Referensi

- Automerge: automerge.org
- `automerge` Dart: pub.dev/packages/automerge
- `automerge-go`: github.com/automerge/automerge-go
- Shapiro et al. (2011). CRDT. SSS 2011.
