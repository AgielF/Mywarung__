# Technical Debt

## Task 7 — Atomicity kasbon transaction
Kondisi: Transaction dan Debt di-insert terpisah. Kalau step 2 gagal, transaksi tetap tersimpan tapi debt tidak. Di-handle dengan SnackBar warning saat ini.
Fix rencana Fase 2: buat usecase/service layer untuk atomic cross-module operation, atau perbaiki dengan pola saga/compensating transaction.
