# ADR-016: Drift Migration Strategy

## Status
Accepted
Tanggal: 2026-09-13

## Context
Proyek ini menggunakan Drift (ADR-014) sebagai local DB untuk mendukung arsitektur offline-first. Saat ini `schemaVersion` berada pada versi 1 (didefinisikan di `app_database.dart`) dan belum ada override `MigrationStrategy` pada `AppDatabase`. Pada Fase 2 (Debt Due Date Reminder), akan dilakukan migrasi pertama (v1 ke v2) dengan menambahkan kolom `due_date` (nullable) di tabel Debts.

Mengingat aplikasi ini adalah aplikasi offline-first dimana pengguna yang sudah ada tidak boleh kehilangan data lokal mereka saat update aplikasi, diperlukan strategi migrasi yang aman, backward-compatible, dan tetap kompatibel dengan proses sinkronisasi Automerge (ADR-013).

## Decision
1. Setiap perubahan schema WAJIB menaikkan `schemaVersion`.
2. WAJIB meng-override `MigrationStrategy` dengan `onUpgrade` (JANGAN mengandalkan default Drift).
3. Migrasi harus bersifat INKREMENTAL: menggunakan pola eksekusi beruntun seperti `if (from < 2)`, `if (from < 3)`, dst — jangan pernah melewati (skip) versi.
4. Kolom baru WAJIB bersifat `nullable` pada tahap awal untuk menjaga backward-compatibility.
5. WAJIB menambahkan test migrasi: membuka DB versi lama dengan kode versi baru, kemudian memverifikasi bahwa data lama (preserved) tetap ada dan kolom baru berhasil ditambahkan.
6. DILARANG keras melakukan destructive migration (drop/recreate) — data user harus selalu preserved.

## Consequences
- **Positif:** Data user aman dari kehilangan, pola penanganan schema change menjadi eksplisit, dan terdapat jaminan test coverage untuk setiap migrasi.
- **Negatif:** Proses perubahan schema menjadi lebih lambat/teliti, membutuhkan pembuatan test migrasi untuk setiap versi, serta meningkatkan sedikit ukuran package karena penambahan kode migrasi.

## Alternatif yang Ditolak
- **Destructive migration (drop & recreate):** Ditolak karena akan menyebabkan kehilangan data secara permanen.
- **Skip migration (memaksa user uninstall aplikasi):** Ditolak karena memberikan user experience yang sangat buruk dan tidak acceptable.
- **Downgrade path:** Tidak didukung untuk menyederhanakan kode dan proses migrasi.

## Referensi
- ADR-013 (CRDT Library)
- ADR-014 (Local DB)
