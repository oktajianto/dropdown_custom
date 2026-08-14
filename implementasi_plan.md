# Implementation Plan — dropdown_custom

Rencana pengembangan plugin dropdown custom untuk Flutter, target publish ke [pub.dev](https://pub.dev).

## Visi

Dropdown yang **setup-nya sederhana tapi serba bisa**. Satu widget generik `CustomDropdown<T>`
yang type-safe, zero-dependency (hanya Flutter SDK), dengan pembeda utama:
**positioning bebas (atas/bawah/kiri/kanan + auto-flip)** yang jarang dimiliki plugin lain.

## Prinsip Desain

1. **Generic `<T>`** — item berupa `List<T>` apapun (String atau model kamu), bukan dibungkus class wajib.
2. **Wajib minimal, opsional banyak** — kasus sederhana cukup 3 baris; fitur lanjutan lewat parameter opsional dengan default masuk akal.
3. **Zero dependency** — hanya `flutter/material`. Maintenance ringan, skor pub.dev tinggi.
4. **Type-safe** — `onChanged` mengembalikan `T`, bukan `dynamic`.

## Kompetitor (yang harus kita kalahkan)

| Package | Kekuatan | Celah yang kita ambil |
|---|---|---|
| `dropdown_button2` | Populer, banyak opsi | Positioning kiri/kanan tidak ada |
| `dropdown_search` | Search + async kuat | API relatif berat |
| `multi_dropdown` | Multiselect bagus | Grouping + search bersamaan kurang mulus |
| `animated_custom_dropdown` | Animasi bagus | Grouping lemah |

**Pembeda utama kita:** positioning 4 arah + auto-flip, grouping + search yang mulus, API minimalis.

## Arsitektur Teknis

- **Overlay + `CompositedTransformFollower`/`CompositedTransformTarget`** untuk menu mengambang
  yang bisa diposisikan atas/bawah/kiri/kanan dan auto-flip saat kena tepi layar.
- **`LayerLink`** menyambungkan trigger dengan menu overlay.
- Struktur package standar: `lib/src/` (implementasi) + barrel export `lib/dropdown_custom.dart`
  + `example/` (wajib untuk skor pub.dev) + `test/`.

## Struktur File

```
lib/
  dropdown_custom.dart          # barrel export (public API)
  src/
    dropdown_direction.dart     # enum posisi
    dropdown_decoration.dart    # konfigurasi warna/style
    custom_dropdown.dart        # widget utama <T>
    dropdown_overlay.dart       # konten menu overlay (list, search, grup)
example/
  lib/main.dart                 # demo semua fitur
test/
  dropdown_custom_test.dart
```

## Roadmap Bertahap

### Fase 1 — Fondasi + Single-select (SEDANG DIKERJAKAN)

- [ ] Enum `DropdownDirection` (top, bottom, left, right, auto)
- [ ] `DropdownDecoration` (highlightColor, backgroundColor, radius, dll.)
- [ ] `CustomDropdown<T>` single-select
  - [ ] Generic `<T>` + `itemLabel` callback
  - [ ] Overlay positioning 4 arah + auto-flip
  - [ ] Search box (`enableSearch`)
  - [ ] Grouping (`groupBy`) dengan group header
  - [ ] Custom warna highlight & background
  - [ ] Disable/enable per item (`isItemEnabled`)
  - [ ] Buka/tutup animasi, tap-outside-to-close, keyboard-friendly
- [ ] Example app menampilkan fitur di atas
- [ ] Unit/widget test dasar

### Fase 2 — Multiselect (SELESAI)

- [x] Named constructor `CustomDropdown<T>.multi(...)`
- [x] Checkbox untuk item terpilih, menu tetap terbuka saat toggle
- [x] `onSelectionChanged(List<T>)`
- [x] `selectedItemsLabel` untuk kustom teks trigger
- [ ] select-all/clear (menyusul bila diperlukan)

### Fase 3 — Async load

- [ ] Named constructor `CustomDropdown<T>.async(...)`
- [ ] `loader: Future<List<T>> Function(String query)`
- [ ] Loading indicator, debounce, empty/error state

### Fase 4 — Polish & rilis pub.dev

- [ ] Dokumentasi lengkap + dartdoc pada API publik
- [ ] `README.md` dengan GIF/screenshot + contoh kode
- [ ] `CHANGELOG.md`, `LICENSE` (MIT)
- [ ] Repo GitHub publik + field `repository`/`homepage` di pubspec
- [ ] `dart pub publish --dry-run` bersih (pana score)
- [ ] Publish

## Keputusan yang Sudah Diambil

- **Nama package:** `dropdown_custom` (tersedia di pub.dev).
- **Model item:** generic `<T>` + callback (bukan class pembungkus wajib).
- **Bahasa dokumentasi:** Inggris.
- **Scope awal:** fondasi + single-select dulu, sisanya bertahap.
- **Lisensi:** MIT (akan difinalkan di Fase 4).
