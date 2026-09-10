---
trigger: always_on
description: >
  Aturan arsitektur POS Warung AI. Terapkan selalu.
---

# Aturan Arsitektur

## Offline-First Adalah Hukum

- Fitur inti (transaksi, stok, kasbon, laporan) WAJIB 100% offline.
- Cloud hanya untuk sync, backup, AI fallback (opt-in).
- Jangan tambah dependensi cloud-only tanpa ADR baru.

## Modular Monolith

- Modul: Sales, Inventory, Customer, Reporting, AI, Sync, Auth.
- Komunikasi antar-modul via interface, bukan direct call.
- Jaga boundary; jangan bocorkan internal modul.

## Multi-Tenancy

- Setiap tabel WAJIB punya `tenant_id`.
- Setiap query WAJIB difilter via RLS (bukan application-level).
- Set tenant context di middleware.

## Target Hardware

- HP Android RAM 2GB
- App size < 50MB
- Model AI < 10MB
- Transaksi < 500ms

## Deployment

- Cloud Run untuk semua service (serverless, murah).
- Cloud SQL PostgreSQL dengan RLS.
- GCS untuk backup & model files.
- Docker Compose untuk lokal (identik dengan cloud).
