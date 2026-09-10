# ADR-001: Offline-First dengan Local DB sebagai Source of Truth

## Status
Accepted — 2026-09-10

## Context

Warung kecil di Indonesia sering menghadapi:
- Koneksi internet tidak stabil atau tidak ada
- Mati listrik yang mematikan router/WiFi
- HP Android dengan RAM terbatas (2GB)
- Kebutuhan operasional yang tidak bisa menunggu koneksi

Pendekatan cloud-first (mayoritas POS SaaS existing) gagal di konteks ini:
- Transaksi tidak bisa dilakukan saat offline
- Data hilang jika aplikasi crash sebelum sync
- UX buruk karena loading terus-menerus

Literatur:
- Pothineni, S. H. (2024). "Offline-First Mobile Architecture." JAIGS.
- Kleppmann, M., et al. (2019). "Local-first software." ACM Onward!.
- CAMS-F Edge DTN (2026). Future Internet, 18(4), 180.
- ISO 9241-210:2019 — Human-Centered Design.

## Decision

Local DB (SQLite/Drift) sebagai **source of truth** untuk semua operasi inti:
- Transaksi penjualan
- Manajemen stok
- Kasbon/utang pelanggan
- Laporan harian

Cloud hanya berperan sebagai:
- Sinkronisasi antar-perangkat (opsional)
- Backup (opsional)
- Fitur yang membutuhkan cloud (AI fallback, marketplace)

Aplikasi **harus 100% berfungsi tanpa internet** untuk fitur inti.

## Consequences

**Positif:**
- Warung tetap bisa beroperasi saat offline/mati listrik
- UX responsif (< 500ms per transaksi)
- Data tidak hilang saat crash
- Privasi lebih baik (data di perangkat pengguna)
- Cloud cost lebih rendah (sync hanya delta)

**Negatif:**
- Kompleksitas sinkronisasi meningkat signifikan
- Butuh strategi conflict resolution (lihat ADR-002)
- Ukuran aplikasi lebih besar (SQLite + model AI)
- Migrasi data antar-perangkat lebih rumit
- Testing lebih kompleks

**Mitigasi:**
- Gunakan CRDT untuk sync (ADR-002)
- Enkripsi lokal dengan SQLCipher
- Backup otomatis ke cloud saat online
- Mode "read-only" saat storage penuh

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Cloud-first dengan cache | Gagal saat offline, UX buruk |
| Hybrid dengan cloud sebagai primary | Kompleksitas tinggi, tetap butuh internet |
| PWA dengan IndexedDB | Terbatas di Android, tidak bisa akses hardware |

## Referensi

- Pothineni, S. H. (2024). JAIGS.
- Kleppmann, M., et al. (2019). ACM Onward!.
- CAMS-F Edge DTN (2026). Future Internet, 18(4), 180.
- ISO 9241-210:2019.
