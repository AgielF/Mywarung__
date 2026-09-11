# Technical Debt

## Task 7 — Atomicity kasbon transaction
Kondisi: Transaction dan Debt di-insert terpisah. Kalau step 2 gagal, transaksi tetap tersimpan tapi debt tidak. Di-handle dengan SnackBar warning saat ini.
Fix rencana Fase 2: buat usecase/service layer untuk atomic cross-module operation, atau perbaiki dengan pola saga/compensating transaction.
## Task 7 — Customer.copyWith tidak bisa set phone ke null
Kondisi: Customer.copyWith pakai pola `??`, jadi `phone` tidak bisa di-reset
ke null setelah diisi.
Fix rencana Task 9 atau Fase 2: pakai sentinel pattern seperti Debt.copyWith
(`String? Function()? phone`).

## Task 7 — Tenant hardcoded 'tenant-1'
Kondisi: Banyak query & UI hardcode tenant 'tenant-1'. Belum ada konteks
tenant aktif.
Fix rencana Fase 2: introduce TenantContext / AuthProvider, inject ke semua
repository.

## Task 7 — Tidak ada validasi format phone
Kondisi: CustomerFormScreen hanya validasi max 20 karakter. Tidak ada
validasi format nomor HP Indonesia.
Fix rencana Task 9: regex validasi (mis. `^08\d{8,11}$`) atau pakai package
phone validation.

## Task 8a — Filter 7 Hari & Custom tidak reaktif
Kondisi: ReportingScreen pakai Stream.fromFuture untuk filter range,
jadi list transaksi tidak auto-update saat ada transaksi baru.
Fix rencana Task 9: tambah watchRangeReport di repository atau polling.
## Task 8b-1 — SalesBarChart overflow untuk days > 7
Kondisi: SalesBarChart pakai Row tanpa scroll horizontal. Kalau days dinaikkan
(> 7), bar akan overflow.
Fix rencana Task 9: bungkus Row dengan SingleChildScrollView horizontal, atau
pakai Flexible per bar.

## Task 8b-1 — Error state "Gagal memuat tren" tanpa tombol retry
Kondisi: Berbeda dengan error state utama ReportingScreen yang punya tombol
"Coba Lagi".
Fix rencana Task 9: tambah tombol retry dengan pola _trendKey + ValueKey.

## Task 8b-1 — getSalesTrend = 7× getDailyReport (21 query untuk 7 hari)
Kondisi: Loop per hari memanggil getDailyReport terpisah.
Fix rencana Fase 2: single query group by date, agregat di SQL.
