# ADR-011: Mobile Framework — Flutter

## Status
Accepted — 2026-09-10

## Context

Proyek butuh framework mobile yang:
- Cross-platform (Android-first, iOS later)
- Performa baik di HP RAM 2GB
- Ekosistem matang untuk offline-first (SQLite, CRDT)
- Mendukung on-device AI (TFLite)
- Familiar untuk developer solo

Pilihan: Flutter, React Native, Native Kotlin.

## Decision

Gunakan **Flutter** dengan alasan:

| Aspek | Flutter | React Native | Native Kotlin |
|---|---|---|---|
| Performa | Rendering sendiri | Bridge overhead | Native |
| Ukuran app | ~15MB | ~7MB | ~5MB |
| RAM 2GB | Baik | Cukup | Terbaik |
| TFLite support | `tflite_flutter` | `react-native-fast-tflite` | Native |
| SQLite | `drift` | `watermelondb` | Room |
| CRDT | `automerge` (Dart) | Terbatas | Terbatas |
| Developer solo | Familiar | Perlu setup | Dua codebase |

## Consequences

**Positif:**
- Satu codebase untuk Android + iOS
- Rendering konsisten di semua device
- Ekosistem paket lengkap (drift, tflite_flutter, automerge)
- Hot reload cepat untuk development

**Negatif:**
- Ukuran app lebih besar (~15MB baseline)
- Perlu belajar Dart jika belum familiar
- Tidak bisa akses native API sedalam Kotlin

**Mitigasi:**
- Gunakan `--split-debug-info` dan `--obfuscate` untuk production
- R8/ProGuard untuk reduce size
- Platform channel untuk native API jika perlu

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| React Native | Bridge overhead, ekosistem CRDT terbatas |
| Native Kotlin | Dua codebase (Android + iOS), developer solo |
| PWA | Tidak bisa akses kamera/TFLite dengan baik |

## Referensi

- Flutter Docs: flutter.dev
- `drift`: drift.simonbinder.eu
- `tflite_flutter`: pub.dev/packages/tflite_flutter
- `automerge`: pub.dev/packages/automerge
