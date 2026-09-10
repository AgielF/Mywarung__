# ADR-002: CRDT untuk Sync, bukan Last-Write-Wins

## Status
Accepted — 2026-09-10

## Context

Dengan offline-first (ADR-001), muncul masalah: bagaimana menyelesaikan konflik ketika dua perangkat (HP owner + HP kasir) mengubah data yang sama saat offline?

Contoh:
- Owner menambah stok Indomie 10 bungkus
- Kasir menjual 5 bungkus Indomie
- Keduanya sync bersamaan

Pendekatan umum:
- Last-Write-Wins (LWW): sederhana, menghilangkan data
- Vector Clock: lebih baik, butuh resolusi manual
- CRDT: otomatis, matematis terjamin

Literatur:
- Shapiro, M., et al. (2011). "Conflict-free Replicated Data Types." SSS 2011.
- IEEE TSE (2025). "Consistent Local-First Software." Vol. 51, Issue 1.
- ConflictSync (2026). ACM Digital Library.

## Decision

Gunakan **CRDT** untuk sinkronisasi:

| Data | CRDT Type | Alasan |
|---|---|---|
| Stok produk | PN-Counter | Bisa naik/turun, commutative |
| Daftar transaksi | G-Set | Transaksi tidak pernah dihapus |
| Kasbon pelanggan | PN-Counter per pelanggan | Bisa nambah/kurangi utang |
| Profil produk | LWW-Register | Metadata, konflik jarang |
| Laporan | Computed | Diturunkan dari data primer |

Implementasi: **Automerge** (ADR-013).

## Consequences

**Positif:**
- Conflict resolution otomatis, tanpa data loss
- Matematis terjamin (commutative, associative, idempotent)
- Bekerja dengan topologi peer-to-peer
- Skalabel untuk multi-perangkat
- Sesuai prinsip local-first

**Negatif:**
- Kompleksitas implementasi tinggi
- Overhead metadata (vector clock, tombstone)
- Tidak semua operasi bisnis bisa dimodelkan sebagai CRDT
- Debugging lebih sulit

**Mitigasi:**
- Gunakan library matang (Automerge), jangan implementasi sendiri
- Dokumentasikan invariant bisnis (stok tidak boleh negatif)
- Gunakan ConLoc-style validation untuk invariants
- Sediakan tool debugging visual

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Last-Write-Wins | Menghilangkan data, tidak acceptable |
| Vector Clock + manual resolution | UX buruk, butuh intervensi user |
| Operational Transformation | Butuh server terpusat |
| Server-authoritative sync | Gagal saat offline |

## Referensi

- Shapiro, M., et al. (2011). SSS 2011.
- IEEE TSE (2025). Vol. 51, Issue 1.
- ConflictSync (2026). ACM Digital Library.
- Automerge: automerge.org
