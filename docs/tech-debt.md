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
# Technical Debt — POS Warung AI

Status terakhir: 11 Sep 2026 — setelah Task 8b-2.

Kategori:
- **FIX DI TASK 9** (Fase 1 polish) — bisa diselesaikan tanpa ADR/schema change
- **TUNDA KE FASE 2** — butuh arsitektur baru (usecase layer, multi-tenant, ADR baru)
- **TUNDA KE TASK SELANJUTNYA** — bug kosmetik / minor

---

## FIX DI TASK 9 (Polish End-to-End)

### TD-01 — Customer.copyWith tidak bisa set phone ke null
**Asal:** Task 7
**Kondisi:** `Customer.copyWith` pakai pola `??`, jadi `phone` tidak bisa di-reset ke null setelah diisi.
**Fix:** Pakai sentinel pattern seperti `Debt.copyWith` (`String? Function()? phone`).
**Effort:** ~15 menit.

### TD-02 — Tidak ada validasi format phone
**Asal:** Task 7
**Kondisi:** `CustomerFormScreen` hanya validasi max 20 karakter. Tidak ada validasi format nomor HP Indonesia.
**Fix:** Regex `^08\d{8,11}$` atau longgar `^[\d\-\+\s]{8,20}$`.
**Effort:** ~15 menit.

### TD-03 — Filter 7 Hari & Custom di ReportingScreen tidak reaktif
**Asal:** Task 8a
**Kondisi:** `ReportingScreen` pakai `Stream.fromFuture` untuk filter range, jadi list tidak auto-update saat ada transaksi baru.
**Fix:** Tambah `watchRangeReport()` di repository, atau polling `Stream.periodic` + `setState`.
**Effort:** ~45 menit.

### TD-04 — FakeReportingRepository & FakeDebtOutstandingRepository di widget_test.dart
**Asal:** Task 8a + 8b-2
**Kondisi:** Fake repository didefinisikan langsung di `widget_test.dart`, tidak reusable.
**Fix:** Pindah ke `test/helpers/fakes.dart`, refactor import.
**Effort:** ~20 menit.

### TD-05 — SalesBarChart overflow untuk days > 7
**Asal:** Task 8b-1
**Kondisi:** `SalesBarChart` pakai `Row` tanpa scroll horizontal. Kalau `days > 7`, bar akan overflow.
**Fix:** Bungkus `Row` dengan `SingleChildScrollView(scrollDirection: Axis.horizontal)`, atau pakai `Flexible` per bar.
**Effort:** ~20 menit.

### TD-06 — Error state "Gagal memuat tren" tanpa tombol retry
**Asal:** Task 8b-1
**Kondisi:** Berbeda dengan error state utama `ReportingScreen` yang punya "Coba Lagi".
**Fix:** Tambah `_trendKey` + `ValueKey` + tombol retry, konsisten dengan pola existing.
**Effort:** ~20 menit.

### TD-07 — customer.name.substring(0, 1) tanpa safety check
**Asal:** Task 8b-2
**Kondisi:** `DebtOutstandingScreen` pakai `summary.customer.name.substring(0, 1)`. Aman karena validasi form min 2 char, tapi rawan kalau data dari sync/import nanti kosong.
**Fix:** Ganti jadi `name.isNotEmpty ? name[0].toUpperCase() : '?'` (pola existing di `sales_screen.dart`).
**Effort:** ~5 menit.

### TD-08 — Cross-domain: Reporting query langsung ke tabel products
**Asal:** Task 8a
**Kondisi:** `DriftReportingRepository._getTransactions` query `_db.products` — tabel modul inventory.
**Fix (Task 9):** Tambah komentar eksplisit + dokumentasi di ADR reporting read-model.
**Fix (Fase 2):** Denormalisasi `product_name` di `transaction_items` saat insert (butuh ADR schema baru).
**Effort:** ~15 menit (komentar + ADR) atau tunda.

---

## TUNDA KE FASE 2

### TD-09 — Atomicity kasbon transaction
**Asal:** Task 7
**Kondisi:** `Transaction` dan `Debt` di-insert terpisah. Kalau step 2 gagal, transaksi tetap tersimpan tapi debt tidak. Di-handle dengan SnackBar warning.
**Fix Fase 2:** Buat usecase/service layer untuk atomic cross-module operation, atau pola saga/compensating transaction.
**Effort:** ~2-3 jam + ADR baru.

### TD-10 — Tenant hardcoded 'tenant-1'
**Asal:** Task 7
**Kondisi:** Banyak query & UI hardcode tenant 'tenant-1'. Belum ada konteks tenant aktif.
**Fix Fase 2:** Introduce `TenantContext` / `AuthProvider`, inject ke semua repository.
**Effort:** ~1-2 hari + ADR baru.

### TD-11 — getSalesTrend = 7× getDailyReport (21 query untuk 7 hari)
**Asal:** Task 8b-1
**Kondisi:** Loop per hari memanggil `getDailyReport` terpisah.
**Fix Fase 2:** Single query `GROUP BY date(created_at)` di SQL, agregat langsung.
**Effort:** ~1 jam.

---

## TUNDA KE TASK SELANJUTNYA (Minor / Kosmetik)

### TD-12 — N+1 query di getById/getAll/watchAll transaction (existing)
**Asal:** Task 6
**Kondisi:** OK untuk skala warung, tapi tidak scalable.
**Fix:** Batch query — tunda sampai ada keluhan performa.

### TD-13 — Transaction.totalAmount redundant (hanya return total)
**Asal:** Task 6
**Kondisi:** Getter hanya wrap field.
**Fix:** Hapus getter, pakai field langsung. Tunda (breaking change kecil).

### TD-14 — dispose() kosong di ReportingScreen & DebtOutstandingScreen
**Asal:** Task 8a, 8b-2
**Kondisi:** Tidak ada subscription/controller, dispose() tidak perlu.
**Fix:** Hapus method. Tunda (tidak berdampak).

### TD-15 — Error handling `_exportCsv` catch generik
**Asal:** Task 8b-1
**Kondisi:** Pesan error tidak include `e` untuk debugging.
**Fix:** `debugPrint('Export CSV error: $e')` (kDebugMode saja). Tunda.


## TUNDA KE FASE 2

### TD-16 — watchRangeReport tanpa tenant filter
**Asal:** Task 9a (TD-03)
**Kondisi:** `_db.select(_db.transactions).watch()` tanpa `.where(tenantId)`.
Saat ini aman karena tenant hardcoded, tapi harus diperbaiki saat multi-tenant aktif.
**Fix Fase 2:** Tambah filter tenant di watch() — butuh TenantContext.

### TD-17 — watchRangeReport refetch full range tiap insert
**Asal:** Task 9a (TD-03)
**Kondisi:** Setiap insert transaksi memicu `getRangeReport` untuk seluruh range
(7 hari = 21 query). Acceptable untuk MVP, tidak scalable.
**Fix Fase 2:** Single query group by date, atau delta update.

## TUNDA KE TASK SELANJUTNYA

### TD-18 — FakeCustomerRepository tidak di helpers
**Asal:** Task 9a (TD-02)
**Kondisi:** `FakeCustomerRepository` didefinisikan lokal di
`customer_form_screen_test.dart`, bukan di `test/helpers/fakes.dart`.
**Fix:** Pindah saat ada penambahan test customer berikutnya.
## TUNDA KE FASE 2

### TD-19 — Debt ↔ Transaction link eksplisit
**Asal:** Task 9b-2 (UX #3)
**Kondisi:** Matching debt ke transaksi by amount — bisa ambigu kalau 2 kasbon amount sama.
**Fix Fase 2:** Tambah `transaction_id` di tabel debts (butuh ADR + migrasi).

### TD-20 — _loadTransactions load semua transaksi
**Asal:** Task 9b-2 (UX #3)
**Kondisi:** `DebtListScreen._loadTransactions()` panggil `getAll()` lalu filter di Dart. Tidak scalable untuk 1000+ transaksi.
**Fix Fase 2:** Tambah method `getByCustomer(customerId, {paymentMethod})` di TransactionRepository.

## TUNDA KE TASK SELANJUTNYA

### TD-21 — Bandingkan enum via string `.name`
**Asal:** Task 9b-2 (UX #3)
**Kondisi:** `t.paymentMethod.name == 'debt'` — tidak type-safe.
**Fix:** Ganti ke `t.paymentMethod == PaymentMethod.debt`.
