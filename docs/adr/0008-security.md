# ADR-008: Security dengan JWT + SQLCipher + RLS

## Status
Accepted — 2026-09-10

## Context

Data warung sensitif (penjualan, utang, pelanggan). Butuh:
- Autentikasi kuat
- Enkripsi data lokal
- Isolasi tenant di database
- Komunikasi aman

Literatur:
- Duende Software (2025). "JWT Best Practices."
- Codecentric (2025). "Self-issued JWT for mobile client authentication."
- OWASP MASVS.
- RFC 7519 (JWT).

## Decision

- **JWT** untuk auth, ECDSA-signed (lebih efisien dari RSA untuk mobile)
- **SQLCipher** untuk enkripsi local DB
- **RLS** untuk isolasi tenant (ADR-006)
- **HTTPS/TLS 1.3** untuk semua komunikasi
- **Secrets** di GCP Secret Manager
- **Password hashing** dengan Argon2id
- **Token refresh** dengan rotating refresh tokens

## Consequences

**Positif:**
- Autentikasi standar industri
- Data lokal terenkripsi
- Isolasi tenant di level DB
- Sesuai OWASP MASVS

**Negatif:**
- Overhead enkripsi (~5-10% performa)
- Manajemen key lebih kompleks
- Butuh rotasi token

**Mitigasi:**
- Gunakan hardware-backed keystore jika tersedia
- Cache key di memory dengan aman
- Dokumentasikan prosedur rotasi

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Session-based auth | Tidak cocok mobile |
| OAuth2 third-party | Overkill, butuh internet |
| Tanpa enkripsi lokal | Melanggar privasi |
| RSA untuk JWT | Lebih besar, lebih lambat |

## Referensi

- RFC 7519 (JWT).
- OWASP MASVS.
- Duende Software (2025).
- Argon2: password-hashing.net
