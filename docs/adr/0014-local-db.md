# ADR-014: Local DB Library — Drift

## Status
Accepted — 2026-09-10

## Context

Butuh local DB untuk Flutter yang:
- SQLite-based (mature, reliable)
- Type-safe query
- Support reactive streams (untuk UI update)
- Support migrations
- Support enkripsi (SQLCipher)

Pilihan: Drift, ObjectBox, Isar, sqflite.

## Decision

Gunakan **Drift** dengan alasan:

| Aspek | Drift | ObjectBox | Isar | sqflite |
|---|---|---|---|---|
| SQLite-based | Ya | NoSQL | NoSQL | Ya |
| Type-safe | Ya | Ya | Ya | Tidak |
| Reactive | Stream | Ya | Ya | Tidak |
| Migrations | Ya | Terbatas | Terbatas | Tidak |
| SQLCipher | Ya | Tidak | Tidak | Terbatas |
| Maturity | 7+ tahun | Ya | Beta | Ya |

## Consequences

**Positif:**
- SQL familiar, mudah di-debug
- Type-safe query (compile-time check)
- Reactive streams untuk UI
- SQLCipher untuk enkripsi (ADR-008)
- Migrations terstruktur

**Negatif:**
- Code generation (build_runner) menambah build time
- Boilerplate untuk setup awal
- Tidak secepat NoSQL untuk write-heavy

**Mitigasi:**
- Gunakan `drift_dev` untuk code generation
- Setup build_runner watch mode
- Index untuk query yang sering

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| ObjectBox | NoSQL, tidak ada SQLCipher |
| Isar | Beta, tidak ada SQLCipher |
| sqflite | Tidak type-safe, manual query |

## Referensi

- Drift: drift.simonbinder.eu
- SQLCipher: zetetic.net/sqlcipher
- `sqlcipher_flutter_libs`: pub.dev
