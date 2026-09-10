# ADR-010: Dokumentasi dengan arc42 + C4 + ADR

## Status
Accepted — 2026-09-10

## Context

Keputusan arsitektur hilang seiring waktu. Butuh:
- Dokumentasi arsitektur terstruktur
- Visualisasi sistem
- Rekam jejak keputusan

Literatur:
- Starke, G., & Hruschka, P. (2005). arc42.
- Brown, S. (2018). C4 Model.
- Nygard, M. (2011). "Documenting Architecture Decisions."
- ISO/IEC/IEEE 42010:2011.

## Decision

- **arc42** untuk dokumentasi arsitektur lengkap (12 chapter)
- **C4 Model** untuk diagram (Context, Container, Component, Code)
- **ADR** (format Nygard) untuk keputusan
- Semua di folder `docs/`
- Diagram: Mermaid (inline) + Draw.io (source)

## Consequences

**Positif:**
- Dokumentasi terstruktur, mudah navigasi
- Diagram konsisten dan dapat di-update
- Keputusan terdokumentasi dengan konteks
- Sesuai standar ISO/IEC/IEEE 42010

**Negatif:**
- Butuh disiplin untuk maintain
- Overhead waktu di awal
- Risiko dokumentasi usang

**Mitigasi:**
- Update dokumentasi setiap PR
- Review dokumentasi di sprint
- Gunakan tooling (Mermaid, arc42 template)

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Wiki (Confluence/Notion) | Tidak versioned dengan kode |
| Hanya README | Tidak cukup untuk arsitektur |
| Tanpa dokumentasi | Keputusan hilang |

## Referensi

- arc42: arc42.org
- C4 Model: c4model.com
- Nygard, M. (2011). cognitect.com
- ISO/IEC/IEEE 42010:2011.
