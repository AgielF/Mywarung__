# ADR-004: Hybrid Chatbot (Local + Cloud LLM)

## Status
Accepted — 2026-09-10

## Context

Fitur diferensiasi: chatbot CRUD via natural language.
- "Tambah stok Indomie 10 bungkus"
- "Hari ini laku berapa?"
- "Catat utang Bu Siti 50rb"

Tantangan:
- LLM cloud butuh internet dan mahal
- LLM cloud bisa halusinasi (berbahaya untuk data bisnis)
- Chatbot harus tetap berfungsi offline (ADR-001)

Literatur:
- GaryAI (2025). IEEE Xplore.
- HNLP-RBV (2026). IEEE ICCMSO.
- Hybrid Chatbot for E-Commerce (2026). IEEE Xplore.
- ACL Anthology — Harel Statecharts + LLMs.

## Decision

Arsitektur hybrid:

**Lapisan 1 — Local (Offline):**
- Rule-based parser untuk perintah umum
- NLU ringan (intent + slot)
- Harel Statecharts untuk dialog
- Coverage: ~80%

**Lapisan 2 — Cloud (Online, opt-in):**
- LLM (Gemini Flash / Claude Haiku)
- Function calling ke API internal
- Rule-based validation sebelum eksekusi
- Coverage: ~20%

**Prinsip:** LLM **tidak pernah** langsung mengubah data. LLM hanya menghasilkan intent + parameters, divalidasi rule-based layer sebelum eksekusi.

## Consequences

**Positif:**
- Berfungsi offline untuk perintah umum
- Biaya LLM rendah
- Mencegah halusinasi
- UX lebih baik

**Negatif:**
- Dua jalur kode
- Perlu training NLU lokal
- Konsistensi response antar lapisan
- Butuh monitoring fallback rate

**Mitigasi:**
- Dokumentasikan intent yang didukung lokal
- Log semua query untuk improvement
- A/B testing antara lokal dan cloud
- Rate limiting untuk LLM cloud

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Full LLM cloud | Butuh internet, mahal, halusinasi |
| Full rule-based | Tidak fleksibel |
| On-device LLM | Terlalu besar (> 1GB) |
| No chatbot | Kehilangan diferensiasi |

## Referensi

- GaryAI (2025). IEEE Xplore.
- HNLP-RBV (2026). IEEE ICCMSO.
- ACL Anthology — Harel Statecharts + LLMs.
- Rasa: rasa.com
