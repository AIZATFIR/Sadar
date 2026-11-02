# Product Requirements Document (PRD): SADAR — Way of Life Habit & Mindfulness Companion

> **Instruksi Penggunaan untuk AI Builder (Lovable, Bolt.new, v0, Cursor, Replit Agent):**
> Dokumen ini adalah spesifikasi lengkap (end-to-end PRD & System Prompt) berdasarkan analisis mendalam dari aplikasi web [SADAR Web App](https://sadar-web.vercel.app/). Bangun aplikasi web **Mobile-First Single Page Application (SPA)** yang interaktif, fungsional penuh, dan memiliki persistensi data (`localStorage`) sesuai dengan seluruh spesifikasi desain, struktur data, copywriting, dan alur interaksi di bawah ini.

## 1. Ringkasan Produk & Filosofi Inti

* **Nama Produk:** SADAR
* **Tagline:** *"Way of Life"* / *"Become conscious of how you live."*
* **Deskripsi Produk:** *"Sadar makes you conscious of how you spend your day, then helps you act on it. Standalone Way of Life habit and mindfulness companion."* — *"Sadar bukan sekadar pelacak kebiasaan, melainkan kompas kesadaran harian."*
* **Referensi Aplikasi Asli:** [SADAR Web App](https://sadar-web.vercel.app/)
* **Value Proposition Utama:**
  * Bukan sekadar *habit tracker* berbasis *streak* yang memberi tekanan atau rasa bersalah, melainkan kompas kesadaran harian (*mindfulness companion*).
  * Menggabungkan 4 dimensi utama: **Eksekusi Harian (Hari Ini)**, **Evaluasi & Matriks Mingguan (Linimasa)**, **Akumulasi Bukti Hidup (Repetisi)**, dan **Pengenalan Pola 30 Hari (Kesadaran)**.
  * Mendukung 4 tipe kebiasaan spesifik: **Timed/Fokus (ala YPT)**, **Count/Hitung**, **Bodybuilding/Rutin**, dan **Hybrid (Set + Durasi)**.

## 2. Rekomendasi Tech Stack untuk AI Builder

| Komponen | Teknologi yang Direkomendasikan | Detail Implementasi |
| :--- | :--- | :--- |
| **Framework UI** | React 18+ (Vite atau Next.js App Router) + TypeScript | Arsitektur SPA responsif dengan *mobile-first viewport container* (`max-w-md mx-auto min-h-screen`) |
| **Styling** | Tailwind CSS | Native Dark Mode dengan palet warna *Charcoal Navy*, *Slate Purple*, dan aksen *Warm Gold/Amber* |
| **Animasi & Transisi** | Framer Motion | Transisi antar tab, *bottom sheet modal*, *onboarding wizard*, dan animasi *circular countdown timer* |
| **Ikonografi** | Lucide React + Native Emoji | Ikon sistem minimalis (*stroke lines*) dipadukan dengan simbol Emoji untuk tiap aktivitas |
| **State & Persistensi** | React Context / Zustand + `localStorage` | Menyimpan daftar kebiasaan, log harian per tanggal, durasi fokus, dan jurnal refleksi harian |

## 3. Sistem Desain & Spesifikasi Visual (UI/UX Design System)

### 3.1. Palet Warna (Color Tokens)

| Token | Kode Hex | Penggunaan Utama |
| :--- | :--- | :--- |
| **Background Primary** | `#121219` | Latar belakang utama halaman dan area luar frame mobile |
| **Background Secondary** | `#16161F` | Latar belakang kontainer aplikasi utama dan header/navigasi |
| **Surface / Card** | `#21212B` | Kartu tugas, kartu statistik, matriks linimasa, dan *bottom sheet* |
| **Surface Border** | `#2E2E3D` | Garis tepi halus pada kartu (`1px solid`) |
| **Primary Accent (Gold)** | `#D4A359` / `#E5B869` | Tombol CTA utama, indikator tab aktif, *progress bar* harian, border tanggal terpilih |
| **Text Primary** | `#F3F4F6` | Judul, nama kebiasaan, angka statistik utama |
| **Text Secondary / Muted** | `#9CA3AF` | Sub-judul, kutipan filosofis, label kategori, *placeholder* |
| **Status: Selesai (Success)** | `#22C55E` | Badge selesai (`✓`), tombol aksi "Ya", border status ritme stabil |
| **Status: Dilewati (Skip)** | `#3B82F6` | Ikon dilewati (`↷`), tombol aksi "Lewati" |
| **Status: Gagal (Failed)** | `#EF4444` | Tombol aksi "Tidak", peringatan kebiasaan yang terlewat |
| **Status: Catatan (Note)** | `#EAB308` | Tombol aksi "Catatan", tag kategori Rutin |

### 3.2. Tipografi & Tata Letak

* **Font Utama (UI & Data):** `Inter` atau `Plus Jakarta Sans` — bersih, modern, dan mudah dibaca pada ukuran kecil.
* **Font Kutipan Filosofis:** `Playfair Display` atau `Instrument Serif` (*Italic*) — digunakan khusus untuk kutipan reflektif di bagian atas halaman Linimasa, Repetisi, dan Kesadaran.
* **Font Jam Digital & Timer:** `JetBrains Mono` atau `tabular-nums` — memastikan angka timer dan jam digital tidak bergeser saat berdetik.
* **Layout Container:** Gunakan kontainer terpusat (`max-w-[430px] mx-auto min-h-screen bg-[#16161F] text-[#F3F4F6] relative pb-24 shadow-2xl border-x border-[#2E2E3D]`) agar tampil rapi seperti aplikasi *native mobile* saat dibuka di layar desktop maupun ponsel.

## 4. Skema Data & Pre-Seeded State (Data Model)

Gunakan struktur data TypeScript berikut dan muat **Data Awal (Pre-Seeded Data)** jika `localStorage` masih kosong agar aplikasi langsung menampilkan pengalaman penuh seperti di [SADAR Web App](https://sadar-web.vercel.app/):

```typescript
export type HabitType = 'timed' | 'count' | 'bodybuilding' | 'hybrid';

export type TagColor = 'amber' | 'blue' | 'yellow' | 'pink' | 'green' | 'purple' | 'cyan';

export interface Habit {
  id: string;
  title: string;
  emoji: string;
  type: HabitType;
  categoryBadge: 'Fokus' | 'Hitung' | 'Rutin' | 'Hybrid';
  targetLabel: string;       // contoh: "45 min", "1x Selesai", "20x repetisi", "3 Set @ 60s"
  durationMinutes?: number;  // untuk tipe timed/hybrid
  targetCount?: number;      // untuk tipe count/bodybuilding
  allowedApps?: string[];    // daftar aplikasi whitelist saat fokus
  color: TagColor;
  accumulatedDays: number;
  accumulatedValueLabel: string; // contoh: "4 hari (3h)", "4 hari (4 m)"
  sessionsLast30Days: number;
}

export type ExecutionStatus = 'pending' | 'done' | 'skipped' | 'failed';

export interface DailyHabitLog {
  date: string; // YYYY-MM-DD
  habitId: string;
  status: ExecutionStatus;
  note?: string;
  completedValueLabel?: string; // contoh: "20x Selesai"
}

export type MoodType = 'reflecting' | 'okay' | 'good' | 'proud';

export interface DailyReflection {
  date: string; // YYYY-MM-DD
  mood: MoodType;
  proudOf: string;
  optionalNote?: string;
}
```

### Data Awal (Default Seed Data)

| Emoji | Nama Kebiasaan | Tipe (`HabitType`) | Badge Kategori | Target Label | Warna Bar | Akumulasi Bukti Hidup | Sesi 30 Hari | Status Hari Ini |
| :---: | :--- | :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| 💻 | **Fokus Coding (LKS)** | `timed` | `Fokus` | `45 min` | Green (`#22C55E`) | `4 hari (3h)` | `4 sesi terpenuhi` | `done` |
| 📖 | **Kalaam 1 Course** | `count` | `Hitung` | `1x Selesai` | Purple (`#A855F7`) | `4 hari (4 m)` | `4 sesi terpenuhi` | `done` |
| 🏋️ | **Senin • Push Up** | `bodybuilding` | `Rutin` | `20x repetisi` | Yellow (`#EAB308`) | `3 hari (1h)` | `3 sesi terpenuhi` | `done` (`20x Selesai`) |
| ⚡ | **Plank & Core** | `hybrid` | `Hybrid` | `3 Set @ 60s` | Pink (`#EC4899`) | `4 hari (12 m)` | `4 sesi terpenuhi` | `pending` |
| 🕊️ | **Sapa Burung / Mindful** | `count` | `Hitung` | `1x Selesai` | Cyan (`#06B6D4`) | `3 hari (3 m)` | `3 sesi terpenuhi` | `pending` |

## 5. Spesifikasi Navigasi & Komponen Global

### 5.1. Top Navigation Bar (Header Tetap)
* **Bagian Tengah:** Judul **SADAR** (huruf kapital, *letter-spacing* lebar `tracking-widest`, bold) dengan sub-judul kecil *Way of Life* berwarna emas redup (`#D4A359`).
* **Bagian Kanan:**
  * Tombol ikon `(i)` (**Info / Filosofi**): Membuka Modal Filosofi & tombol pemicu Onboarding.
  * Tombol ikon `+` (**Tambah Kebiasaan**): Membuka *Bottom Sheet Modal* pembuatan kebiasaan baru.

### 5.2. Sticky Bottom Navigation Bar (4 Tab Utama)
Menempel di bagian bawah kontainer (`fixed bottom-0 max-w-[430px] w-full bg-[#16161F]/95 backdrop-blur border-t border-[#2E2E3D]`). Terdiri dari 4 tab:
1. ☀️ **Hari Ini** (*Home / Today View*)
2. ▦ **Linimasa** (*Calendar Matrix & Execution Tracker*)
3. ⇄ **Repetisi** (*Accumulated Progress & Habit Proof*)
4. 👁 **Kesadaran** (*30-Day Analytics & Pattern Recognition*)

## 6. Spesifikasi Layar per Tab (Screen-by-Screen Breakdown)

### 6.1. Tab 1: "Hari Ini" (Today View)
1. **Header Sapaan Personal:**
   * Sapaan dinamis sesuai waktu (atau default): *"Selamat pagi, Zafir."* (dapat diedit jika diklik).
   * Sub-header filosofis: *"How do you want to live today?"*
2. **Section Header "TODAY":**
   * Label kiri: `TODAY` (huruf kapital kecil, *muted*).
   * Sebelah kanan: Tombol `+ Add` berdampingan dengan indikator progres `3 / 5 done`.
3. **Daftar Kartu Tugas Harian (Habit List Cards):**
   * Setiap kartu (`bg-[#21212B] rounded-xl p-4 mb-3 border border-[#2E2E3D]`) menampilkan:
     * **Checkbox Kustom:** Lingkaran/kotak yang berubah menjadi hijau (`#22C55E`) dengan tanda centang `✓` saat selesai, serta memberi efek *strikethrough* halus atau redup pada judul.
     * **Emoji & Nama Kebiasaan:** Contoh `💻 Fokus Coding (LKS)`.
     * **Baris Metadata:** Badge kategori berwarna (`Fokus` warna amber, `Hitung` warna biru, `Rutin` warna kuning, `Hybrid` warna pink) + teks target (`45 min`, `1x Selesai`, `20x repetisi`, `3 Set @ 60s`) + badge hasil jika sudah selesai (contoh: `20x Selesai`).
     * **Menu Konteks (`⋮`):** Klik untuk membuka aksi cepat: *Mulai Timer Fokus*, *Edit Kebiasaan*, *Tandai Lewati (Skip)*, atau *Hapus*.
4. **Section Refleksi Harian:**
   * Kartu interaktif `🤍 Refleksi` dengan sub-teks placeholder *"Rasa hari ini"*.
   * Jika pengguna sudah mengisi refleksi hari ini, tampilkan badge mood terpilih (misal `🌿 Good` atau `🌟 Proud`) dan cuplikan catatan kebanggaan hari ini.
   * Klik kartu ini untuk membuka **Modal Refleksi Harian**.
5. **Real-Time Digital Clock Widget:**
   * Di bagian bawah daftar sebelum navigasi bawah, tampilkan jam digital real-time berukuran tenang dan minimalis (contoh: `11:54 AM`) yang diperbarui setiap detik.

### 6.2. Tab 2: "Linimasa" (Timeline & Execution Matrix)
1. **Kartu Evaluasi Harian (Top Evaluation Card):**
   * Header Tanggal: Contoh *Thursday, 15 October* dilengkapi badge emas `HARI INI`.
   * Kutipan Reflektif (Italic Serif): *“Did I live today in a way I can be proud of?”*
   * **Gold Progress Bar:** Indikator bar berwarna emas (`#D4A359`) dengan teks kiri *"3 / 5 tindakan bermakna terlaksana"* dan label kanan *"Membangun Hari"*.
2. **Pemilih Minggu (Week Selector Grid):**
   * Header: *Minggu Ini (12 - 18 Okt 2026)* dengan tombol navigasi panah `<` dan `>` untuk berpindah minggu.
   * Grid 7 Hari (`SEN 12`, `SEL 13`, `RAB 14`, `KAM 15`, `JUM 16`, `SAB 17`, `MIN 18`). Hari yang sedang dipilih memiliki outline/fill aksen emas (`#D4A359`).
3. **Matriks Status Kebiasaan (Habit Status Matrix):**
   * Tabel/grid riwayat pelaksanaan setiap kebiasaan selama 7 hari dalam minggu terpilih:
     * `✓` (Lingkaran/kotak Hijau `#22C55E`): Selesai (`done`)
     * `↷` (Lingkaran/kotak Biru `#3B82F6`): Dilewati (`skipped`)
     * `✕` (Lingkaran/kotak Merah `#EF4444`): Tidak terlaksana (`failed`)
     * Kotak kosong (`border-[#2E2E3D]`): Belum diisi (`pending`)
4. **Panel Aksi Cepat per Tugas (Task Action Cards):**
   * Di bawah matriks, tampilkan daftar kartu kebiasaan untuk tanggal yang sedang dipilih, lengkap dengan baris tombol aksi cepat:
     * **Mulai Timer** (Tombol dengan outline emas `#D4A359` — memicu layar *Full-Screen Focus Timer*)
     * **Catatan** (Tombol kuning `#EAB308` — membuka input catatan singkat untuk tugas tersebut)
     * **Ya** (Tombol hijau `#22C55E` — menandai status `done`)
     * **Tidak** (Tombol merah `#EF4444` — menandai status `failed`)
     * **Lewati** (Tombol biru `#3B82F6` — menandai status `skipped`)

### 6.3. Tab 3: "Repetisi" (Accumulated Progress & Habit Proof)
1. **Header Filosofi Repetisi:**
   * Ikon `⇄` dengan judul **WHAT YOU REPEAT**.
   * Kutipan (Italic Serif): *“We are what we repeatedly do.”*
   * Sub-teks penjelasan: *"Satu sesi tampak kecil. Ratusan sesi yang diulang menjadi pola hidupmu yang sesungguhnya."*
2. **Section "AKUMULASI BUKTI HIDUP":**
   * Menampilkan daftar kartu akumulasi untuk setiap kebiasaan.
   * Setiap kartu memuat:
     * Emoji + Nama Kebiasaan di sisi kiri.
     * Metrik akumulasi di sisi kanan: contoh `4 hari (3h)`, `4 hari (4 m)`, `4 hari (12 m)`, `3 hari (1h)`, `3 hari (3 m)`.
     * **Horizontal Progress Bar** dengan warna khas masing-masing kebiasaan (Hijau, Ungu, Pink, Kuning, Cyan) yang proporsional terhadap target konsistensi (misal target milestone 30 hari / 100 sesi).
   * Saat pengguna menyelesaikan sesi baru di tab *Hari Ini* atau *Timer Fokus*, angka akumulasi hari dan durasi/menit pada tab ini otomatis bertambah secara dinamis.

### 6.4. Tab 4: "Kesadaran" (30-Day Analytics & Pattern Recognition)
1. **Header Prinsip Kesadaran:**
   * Ikon `👁` dengan judul **PRINSIP KESADARAN**.
   * Kutipan Carl Jung (Italic Serif): *“Until you make the unconscious conscious, it will direct your life and you will call it fate.”*
   * Sub-teks penjelasan: *"Aplikasi ini hadir bukan untuk menghakimimu, melainkan untuk menyadarkan pola nyata yang berulang dalam hidupmu."*
2. **Section "APA YANG BERULANG KALI KAU LAKUKAN?":**
   * Menampilkan kartu statistik 30 hari terakhir untuk masing-masing kebiasaan:
     * Emoji + Nama Kebiasaan
     * Sub-teks: `4 sesi terpenuhi (30 hari terakhir)`
     * Badge kanan: `4 ✓` (dalam pill berwarna hijau/emas).
3. **Section "POLA YANG MEMBUTUHKAN PERHATIAN":**
   * Kotak diagnostik pintar yang mengevaluasi konsistensi pengguna minggu ini:
     * **Kondisi Stabil (Default/Hijau):** Kotak dengan border hijau (`#22C55E`) dan teks *"✓ Semua kebiasaan berjalan dengan ritme yang stabil minggu ini. Pertahankan ketenanganmu."*
     * **Kondisi Perlu Perhatian (Dinamis):** Jika ada kebiasaan yang berstatus `failed` atau `skipped` ≥ 2 kali dalam minggu berjalan, tampilkan kotak peringatan lembut (border Amber/Merah) yang menyebutkan nama kebiasaan tersebut agar pengguna kembali menyadarinya tanpa menghakimi.

## 7. Spesifikasi Modal & Alur Interaksi (Interactive User Flows)

### 7.1. Modal Filosofi `(i)` & 5-Step Onboarding Walkthrough
* Saat ikon `(i)` di header diklik, tampilkan modal informasi singkat tentang filosofi **SADAR** (*"Sadar bukan sekadar pelacak kebiasaan, melainkan kompas kesadaran harian"*) disertai tombol CTA **`Buka Panduan`**.
* Jika **`Buka Panduan`** diklik, tampilkan *Full-Screen Onboarding Wizard* 5 langkah:
  1. **Slide 1 (Intro):** Logo **SADAR**, tagline *“Become conscious of how you live.”*, deskripsi singkat, dan tombol CTA **`Begin`**.
  2. **Slide 2 (Prioritas Hidup):** Judul *“What matters to you?”* — Grid pilihan *chip/card* multi-pilih: `Quran`, `Learning`, `Exercise`, `Language`, `Creative Work`, `Family`, `Reflection`.
  3. **Slide 3 (Inspirasi Kebiasaan):** Judul *“Inspirasi Kebiasaan”* — Menampilkan rekomendasi kartu kebiasaan berdasarkan kategori yang dipilih beserta estimasi waktu (dapat diklik untuk langsung ditambahkan).
  4. **Slide 4 (Komitmen Realistis):** Judul *“How much is realistic?”* — Slider atau pilihan target waktu harian yang rasional dengan pesan filosofis: *"15 minutes practiced 100 times shapes your life."*
  5. **Slide 5 (Penutup):** Judul *“That's enough.”* — Pesan penegas ketenangan pikiran dan tombol CTA **`Enter Sadar`** untuk kembali ke dashboard utama.

### 7.2. Modal Tambah / Edit Kebiasaan (`+` / `+ Add`)
Berupa *Bottom Sheet Modal* dengan komponen input berikut:
1. **Nama Kebiasaan:** Text input dengan placeholder *"misal: Deep Work, Olahraga, Belajar Bahasa, Membaca"*.
2. **Pilih Simbol / Emoji:** Grid pemilih emoji interaktif (`📖`, `💻`, `🏋️`, `🏃`, `🧘`, `📚`, `✍️`, `⚡`, `🕊️`, `🎯`, `🧠`, `🌿`).
3. **Tipe Kebiasaan (Segmented Control 4 Opsi):**
   * `⏱️ Timed (YPT)` → menghasilkan badge kategori `Fokus`
   * `1234 Count` → menghasilkan badge kategori `Hitung`
   * `🏋️ Bodybuilding` → menghasilkan badge kategori `Rutin`
   * `⚡ Hybrid` → menghasilkan badge kategori `Hybrid`
4. **Input Parameter Dinamis (Berubah Sesuai Tipe Kebiasaan):**
   * Jika `Timed (YPT)`: Input angka **Durasi Fokus (Menit)** (default: `20`).
   * Jika `Count`: Input angka **Target Hitungan Harian** (default: `1` kali selesai).
   * Jika `Bodybuilding`: Input **Target Repetisi / Set** (contoh: `20x repetisi`).
   * Jika `Hybrid`: Input **Jumlah Set & Durasi Detik** (contoh: `3 Set @ 60s`).
5. **Pilih Aplikasi Diizinkan (Whitelist App Blocker UI):**
   * Pilihan *multi-select chips* aplikasi yang diizinkan saat mode fokus berjalan (contoh: `VS Code`, `Notion`, `Al-Quran App`, `Browser Edukasi`, `Spotify`).
6. **Warna Tag:** Pemilih lingkaran warna (`Green`, `Blue`, `Yellow`, `Orange`, `Purple`, `Pink`, `Cyan`).
7. **Tombol Submit:** **`Buat Kebiasaan`** (warna emas `#D4A359`, teks gelap bold) yang langsung menambahkan item ke daftar kebiasaan aktif.

### 7.3. Layar Mode Timer Fokus (`Mulai Timer`)
* Dipicu dari tombol **`Mulai Timer`** pada tab *Linimasa* atau dari menu `⋮` pada tab *Hari Ini*.
* Menampilkan *Full-Screen Focus Overlay* (`bg-[#121219] z-50`):
  * Label atas: Emoji + Nama Kebiasaan & daftar aplikasi *whitelist* yang diizinkan.
  * **Circular Countdown Timer:** Lingkaran SVG besar dengan *stroke progress* berwarna emas (`#D4A359`) yang berkurang secara halus, menampilkan sisa waktu dalam format `MM:SS` (misal `45:00`).
  * Kutipan penyemangat di bawah timer: *"Stay with it. Fulfill your day."*
  * **Tombol Kontrol:**
    * `⏸ Jeda` / `▶ Lanjut` (Outline button)
    * `✓ Selesai` (Solid Gold/Green button — menghentikan timer, menandai kebiasaan hari ini sebagai `done`, dan menambahkan durasi ke akumulasi **Repetisi**).

### 7.4. Modal Refleksi Harian (`🤍 Refleksi`)
* Dipicu saat pengguna menekan kartu `🤍 Refleksi` di tab *Hari Ini*.
* Menampilkan modal dengan form reflektif:
  1. **Pilihan Mood / Perasaan Hari Ini (4 Kartu Pilihan):**
     * 🌧️ *Reflecting*
     * ☁️ *Okay*
     * 🌿 *Good*
     * 🌟 *Proud*
  2. **Input Teks 1 (Wajib):** Label `"TODAY I AM PROUD THAT..."` — Textarea untuk menuliskan satu hal bermakna yang disyukuri/dibanggakan hari ini.
  3. **Input Teks 2 (Opsional):** Label `"OPTIONAL NOTE"` — Textarea untuk catatan tambahan.
  4. **Tombol Submit:** **`Save Reflection`** — menyimpan refleksi ke `localStorage` untuk tanggal hari ini dan memperbarui tampilan kartu `🤍 Refleksi` di halaman utama.

## 8. Daftar Periksa Kesiapan untuk AI Builder (Acceptance Criteria)

* [ ] Seluruh 4 tab utama (**Hari Ini**, **Linimasa**, **Repetisi**, **Kesadaran**) dapat dinavigasi secara instan tanpa *page reload*.
* [ ] Data awal (*5 default habits*) langsung termuat dengan status `3 / 5 done` sehingga pengguna langsung melihat visualisasi bar dan matriks yang hidup.
* [ ] Mencentrang tugas di tab **Hari Ini** atau menekan tombol **Ya / Tidak / Lewati** di tab **Linimasa** saling tersinkronisasi secara real-time dan memperbarui *Gold Progress Bar* serta angka di tab **Repetisi** & **Kesadaran**.
* [ ] Fitur **Tambah Kebiasaan (`+`)**, **Panduan Onboarding (`(i)` -> `Buka Panduan`)**, **Timer Fokus (`Mulai Timer`)**, dan **Refleksi Harian (`🤍 Refleksi`)** berfungsi penuh tanpa menggunakan *placeholder* statis yang mati.
* [ ] Jam digital real-time di bagian bawah tab **Hari Ini** berjalan akurat mengikuti waktu perangkat pengguna.
