# ADR-015: Chatbot NLU — Custom Rule-Based + Rasa

## Status
Accepted — 2026-09-10

## Context

Butuh NLU untuk chatbot lokal (offline) yang:
- Ringan (< 5MB)
- Mendukung Bahasa Indonesia
- Bisa handle intent CRUD (create, read, update, delete)
- Bisa jalan offline
- Fallback ke LLM cloud jika perlu

Pilihan: Rasa NLU, Dialogflow, custom rule-based, spaCy.

## Decision

Gunakan **hybrid tiga lapis**:

**Lapisan 1 — Custom Rule-Based (Offline):**
- Pattern matching dengan regex + keyword
- Intent classification sederhana
- Slot filling manual
- Coverage: ~80% perintah umum

**Lapisan 2 — Rasa NLU (Opsional, bundled):**
- Untuk intent yang lebih kompleks
- Model kecil (~5MB)
- Bisa di-train offline

**Lapisan 3 — LLM Cloud (Fallback, opt-in):**
- Gemini Flash / Claude Haiku
- Hanya jika online
- Function calling ke API internal

## Consequences

**Positif:**
- Lapisan 1 jalan 100% offline
- Ringan, tidak butuh model besar
- Full control atas behavior
- Bisa di-test dengan mudah

**Negatif:**
- Rule-based terbatas untuk variasi bahasa
- Rasa butuh training data
- Tiga lapisan kode

**Mitigasi:**
- Mulai dari rule-based, tambah Rasa jika perlu
- Log semua query untuk improvement
- LLM fallback untuk edge cases

## Contoh Intent

| Intent | Contoh Perintah | Handler |
|---|---|---|
| `add_stock` | "Tambah stok Indomie 10 bungkus" | Rule-based |
| `check_sales` | "Hari ini laku berapa?" | Rule-based |
| `add_debt` | "Catat utang Bu Siti 50rb" | Rule-based |
| `delete_product` | "Hapus produk yang sudah tidak dijual" | Rasa/LLM |
| `analyze_trend` | "Produk apa yang paling laku bulan ini?" | LLM |

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Full Dialogflow | Butuh internet, mahal |
| Full spaCy | Model besar (> 50MB) |
| Full LLM | Butuh internet, halusinasi |

## Referensi

- Rasa: rasa.com
- GaryAI (2025). IEEE Xplore.
- HNLP-RBV (2026). IEEE ICCMSO.
