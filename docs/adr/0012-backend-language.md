# ADR-012: Backend Language — Go

## Status
Accepted — 2026-09-10

## Context

Backend butuh:
- Performa tinggi untuk sync service (WebSocket, banyak koneksi)
- Binary kecil untuk Cloud Run (cold start cepat)
- Ekosistem matang untuk PostgreSQL, JWT, WebSocket
- Familiar untuk developer solo

Pilihan: Go, Python (FastAPI), Node.js.

## Decision

Gunakan **Go** untuk backend utama, dengan **Python** hanya untuk AI service (LLM orchestration).

| Aspek | Go | Python | Node.js |
|---|---|---|---|
| Performa | Tinggi | Sedang | Tinggi |
| Cold start | < 100ms | ~500ms | ~200ms |
| Binary size | ~10MB | ~200MB | ~50MB |
| WebSocket | Native | Butuh lib | Socket.io |
| PostgreSQL | `pgx` | `asyncpg` | `pg` |
| JWT | `golang-jwt` | `python-jose` | `jsonwebtoken` |
| Concurrency | Goroutine | Async | Event loop |

## Consequences

**Positif:**
- Cold start cepat di Cloud Run (hemat biaya)
- Binary kecil, container ringan
- Goroutine cocok untuk sync service (ribuan koneksi)
- Type safety, compile-time error detection

**Negatif:**
- Verbose (error handling eksplisit)
- Ekosistem AI/ML terbatas (makanya AI service pakai Python)
- Perlu belajar jika belum familiar

**Mitigasi:**
- AI service terpisah dalam Python (FastAPI)
- Shared contract via OpenAPI/gRPC
- Gunakan `sqlc` untuk generate query dari SQL

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Python (FastAPI) all-in | Cold start lambat, binary besar |
| Node.js | Tidak sekuat Go untuk concurrency |
| Rust | Overkill, learning curve tinggi |

## Referensi

- Go: go.dev
- `pgx`: github.com/jackc/pgx
- `golang-jwt`: github.com/golang-jwt/jwt
- `sqlc`: sqlc.dev
