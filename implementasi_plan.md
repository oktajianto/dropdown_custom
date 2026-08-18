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
- [x] select-all/clear opsional (`showSelectAll`, default off; hormati filter
      search & lewati item disable; label bisa dikustom)

### Fase 3 — Async load (SELESAI)

- [x] Named constructor `CustomDropdown<T>.async(...)`
- [x] `loader: Future<List<T>> Function(String query)`
- [x] Loading indicator, debounce, empty/error state + retry
- [x] Race-guard (request id) agar respons lama tak menimpa yang baru
- [x] Loading indicator bisa dikustom via `DropdownLoading`:
      circular / shimmer skeleton / custom widget, plus warna bisa diatur
      (shimmer diimplement sendiri tanpa dependency)
- [x] Empty & error state bisa dikustom (`emptyBuilder`, `errorBuilder`);
      `errorBuilder` menerima error + callback retry
- [ ] Async multi-select (menyusul bila diperlukan)

### Fase 3.5 — Styling granular (SELESAI)

- [x] Pisah styling jadi 3 grup independen (ganti `DropdownDecoration`):
      `DropdownFieldStyle` (input), `DropdownMenuStyle` (kotak+list),
      `DropdownSearchStyle` (searchbar)
- [x] Input & menu bisa diwarnai terpisah; searchbar fully themable
      (fill, border, focused border, hint, text, icon)

### Fase 4 — Polish & rilis pub.dev

- [x] Dokumentasi lengkap + dartdoc pada API publik
- [x] `README.md` dengan contoh kode lengkap + badge (flutter/dart/platform/
      license/pub/likes/points/stars) + GIF preview (`screenshots/example-1.gif`)
- [x] `CHANGELOG.md`, `LICENSE` (MIT)
- [x] Repo GitHub publik + field `repository`/`homepage` di pubspec
- [x] `topics` di pubspec + constraint SDK/Flutter yang benar
- [x] Archive ramping (26 KB) — `example/build` dikecualikan via `.pubignore`
- [x] `dart pub publish --dry-run` bersih (0 warning saat git clean)
- [x] **Publish**

### Fase 5 — Fitur lanjutan pasca-rilis (SEDANG DIKERJAKAN)

Fitur tambahan setelah v0.4.0 rilis. Semua opsional & backward-compatible.
Diurutkan dari nilai tertinggi.

**Prioritas tinggi**

- [x] **Clearable single-select** (v0.5.0) — `clearable: true` menampilkan tombol
      ✕ di trigger saat ada value; menghapus lewat callback `onCleared` (karena
      `onChanged` mengembalikan `T` non-null). Tersedia di konstruktor default &
      `.async`. Sudah ada test, contoh, README, CHANGELOG.
- [x] **Integrasi Form / validasi** (v0.5.0) — `validator` + `autovalidateMode`
      di ketiga konstruktor; dropdown jadi `FormField` (ikut `Form.validate()`/
      `save()`). Saat gagal: pesan error tampil di bawah trigger **dan outline
      jadi merah** (`colorScheme.error`). Single/async memvalidasi `T?`, `.multi`
      memvalidasi `List<T>`. Sudah ada test, contoh (section 8), README, CHANGELOG.
- [x] **Keyboard navigation + accessibility** (v0.5.0) — panah ↑↓ pindah
      highlight (lewati header & item disabled), Enter pilih, Esc tutup; jalan
      juga saat fokus di search box (handler di `FocusNode.onKeyEvent` leaf,
      mendahului text-editing). Highlight auto-scroll & mulai dari item terpilih.
      `Semantics` pada trigger (button + expanded + label) dan tiap item
      (selected/checked + enabled + label). Sudah ada test.

**Prioritas menengah**

- [x] **Chips untuk multi-select** (v0.5.0) — `showChips: true` menampilkan chip
      yang bisa dihapus per item (✕ per chip, tanpa buka menu). `chipOverflow`
      pilih wrap (default) / scroll horizontal; `chipStyle` (`DropdownChipStyle`)
      untuk warna (default turun dari `menuStyle`/tema). `selectedItemsLabel`
      tetap dipakai saat `showChips: false`. Sudah ada test, contoh, README.
- [x] **DropdownController** (v0.5.0) — `open()`/`close()`/`toggle()` + `isOpen`
      programatik; `ChangeNotifier` (bisa di-listen). Tersedia di ketiga
      konstruktor. Implementasi pakai pola `part` agar controller mengakses aksi
      internal state tanpa membocorkan API. Sudah ada test, contoh (section 9),
      README.
- [x] **Batas maksimal pilihan (multi-select)** (v0.5.0) — `maxSelection: n`;
      saat batas tercapai item belum-terpilih dinonaktifkan (yang terpilih tetap
      bisa di-uncheck), select-all & keyboard nav ikut menghormati batas. Sudah
      ada test, contoh (section 4), README.

**Prioritas rendah (nice-to-have)**

- [ ] **Animasi buka/tutup menu** (fade/scale/slide).
- [ ] **Infinite scroll / pagination** untuk `.async` list besar.
- [ ] **Opsi "tambah baru"** (tags style) — masukkan nilai di luar list.

## Keputusan yang Sudah Diambil

- **Nama package:** `dropdown_custom` (tersedia di pub.dev).
- **Model item:** generic `<T>` + callback (bukan class pembungkus wajib).
- **Bahasa dokumentasi:** Inggris.
- **Scope awal:** fondasi + single-select dulu, sisanya bertahap.
- **Lisensi:** MIT.
