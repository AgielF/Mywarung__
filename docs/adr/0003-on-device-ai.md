# ADR-003: On-Device AI untuk Computer Vision

## Status
Accepted — 2026-09-10

## Context

Fitur diferensiasi: deteksi produk tanpa barcode (gorengan, kue, rokok ketengan, produk curah).

Cloud vision bermasalah:
- Butuh internet (bertentangan dengan ADR-001)
- Latency tinggi (> 2 detik)
- Biaya per request mahal
- Privasi: gambar terkirim ke server

Literatur:
- Somvanshi, S., et al. (2025). "From TinyML to TinyDL." ACM Computing Surveys.
- Cordova-Cardenas, R., et al. "Edge AI in Practice." MDPI Sensors.
- IEEE Xplore (2026). "Compact Edge-AI Architecture."
- QuantEdge (2025). IEEE Xplore.

## Decision

On-device AI dengan spesifikasi:

| Aspek | Keputusan |
|---|---|
| Runtime | TFLite (utama) atau ONNX Runtime Mobile |
| Model | MobileNetV3 / EfficientNet-Lite / YOLOv8-nano |
| Ukuran | < 10MB (INT8 quantized) |
| Input | 224×224 atau 320×320 |
| Output | Klasifikasi produk + confidence |
| Fallback | Manual jika confidence < 70% |
| Target akurasi | 85% untuk 50 produk populer |

Model dilatih **offline** (laptop/server), di-deploy ke perangkat. Tidak ada on-device training.

## Consequences

**Positif:**
- Berfungsi 100% offline
- Latency rendah (< 500ms)
- Privasi terjaga
- Biaya marginal nol
- Sesuai prinsip local-first

**Negatif:**
- Akurasi terbatas (model kecil)
- Ukuran aplikasi bertambah (~10MB)
- Butuh HP dengan kamera memadai
- Update model butuh download ulang

**Mitigasi:**
- Kuantisasi INT8
- Fallback manual untuk confidence rendah
- Update model via delta download
- Kumpulkan dataset bertahap (crowdsourcing opt-in)

## Alternatif yang Ditolak

| Alternatif | Alasan Ditolak |
|---|---|
| Cloud Vision API | Butuh internet, mahal, privasi buruk |
| Hybrid on-device + cloud | Kompleksitas tinggi |
| Barcode-only | Tidak menyelesaikan produk tanpa barcode |
| RFID/NFC | Butuh hardware tambahan |

## Referensi

- Somvanshi et al. (2025). ACM Computing Surveys.
- Cordova-Cardenas et al. MDPI Sensors.
- IEEE Xplore (2026). Compact Edge-AI.
- QuantEdge (2025). IEEE Xplore.
- TFLite: tensorflow.org/lite
