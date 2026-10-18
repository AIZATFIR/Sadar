# AUDIT_APPLE_DESIGN.md

Laporan Evaluasi Antarmuka Fluid Berbasis Apple Design (WWDC 2018 — *Designing Fluid Interfaces*)
Proyek: **Sadar** — Way of Life habit & mindfulness companion (web)

**Tanggal:** 18 Oktober 2026  
**Evaluator:** AI Agent (mengacu pada skill `apple-design` dari `~/.opencode/skills/apple-design/SKILL.md`)  
**Target yang dievaluasi:** `public/index.html` (identik byte-for-byte dengan `index.html` di root dan `web_app/index.html`)

---

## 1. Lingkup Audit

| File | Peran | Status dalam audit |
|------|-------|-------------------|
| `public/index.html` | HTML + CSS inline (`<style>`) + JS aplikasi sepenuhnya inline (`<script>` ~1.430 baris) | **Dievaluasi penuh** |
| `index.html` (root) | Salinan identik `public/index.html` | Ditunjuk ke laporan ini |
| `web_app/index.html` | Salinan identik `public/index.html` | Ditunjuk ke laporan ini |
| `web/index.html` | Bootstrap Flutter default (minimal, bukan UI Sadar) | Catatan: bukan target utama |
| `public/main.dart.js` | Keluaran kompilasi Flutter (dart2js) | Di luar cakupan (bukan sumber tulisan tangan) |
| `public/flutter_bootstrap.js`, `flutter.js`, `flutter_service_worker.js` | Loader & service worker Flutter | Di luar cakupan UI |

**Tidak ada file `.css` atau `.js` aplikasi terpisah.** Seluruh gaya dan interaksi hidup dalam satu file HTML. Semua temuan dan rekomendasi kode berikut merujuk pada `public/index.html` (terapkan sama pada kedua salinan lainnya).

---

## 2. Metode Evaluasi

Audit ini menggunakan kerangka **apple-design** (distilasi WWDC 2018 *Designing Fluid Interfaces* untuk web), yang mengukur interface melalui kebutuhan manusia: safety/predictability, understanding, achievement, joy. Delapan dimensi utama yang dievaluasi:

1. Response — kill latency (zero latency)
2. Direct manipulation — 1:1 tracking
3. Interruptibility
4. Behavior over animation — springs
5. Velocity handoff & momentum projection
6. Spatial consistency
7. Rubber-banding — soft boundaries
8. Materials & depth (translucency)
9. Multimodal feedback (motion + sound + haptics)
10. Reduced motion & accessibility
11. Typography
12. Design foundations (8 principles)

Setiap dimensi diberi temuan (what exists), gap (what Apple design expects), dan rekomendasi kode konkret.

---

## 3. Ringkasan Eksekutif

Sadar sudah memiliki **intuisi visual yang tepat**: warna gelap (dark mode), aksen emas (`#D4A359`), kaca blur (`backdrop-filter`), tombol tekanan (`apple-press`), dan tipografi bermuatan (Plus Jakarta Sans, Playfair Display, JetBrains Mono). Namun, dari sudut **fluid interface**, aplikasi masih terasa seperti "halaman web statis yang diganti isinya", bukan "objek fisik yang dapat disentuh".

Masalah struktural utama:
- **Tidak ada spring sama sekali.** Semua gerakan adalah CSS transition fixed-duration (`duration-500`, `duration-700`, `duration-1000`) atau perpindahan instan via `innerHTML`.
- **Tidak ada gesture / drag.** Tidak ada Pointer Events, `setPointerCapture`, atau tracking 1:1 jari→konten. Semua interaksi adalah `onclick` → ganti layar seketika.
- **Tidak ada velocity handoff.** Saat gestur berakhir, animasi tidak melanjutkan kecepatan jari; tidak ada projected landing point.
- **Interaksi tidak dapat diinterupsi.** Sebuah modal yang sedang buka tidak bisa di-grab dan diturunkan kembali oleh jari pada tengah jalan.
- **Re-render paksa.** Setiap perubahan state mengganti seluruh `innerHTML` tab — fokus hilang, layar berkedip, tidak halus.
- **Tidak ada dukungan reduced motion / reduced transparency / contrast.** Melanggar aksesibilitas Apple.
- **Tidak ada umpan balik multimodal.** Tidak ada haptik (Vibration API), nada, atau getaran saat komitmen aksi.

Skor kearifan fluid (estimasi): **2,5 / 10** pada dimensi motion & gesture; **6,5 / 10** pada dimensi visual & materi.

---

## 4. Analisis Per Dimensi

### 4.1 Response — Kill Latency (Zero Latency)

**Apa yang ada:**
- `.apple-press` merespons `:active` segera (transform scale 0.965, opacity 0.88) — baik, ini adalah feedback pada pointer-down, bukan pada release.
- Tampilan digital jam diperbarui setiap 1 detik via `setInterval`.
- Timer fokus menghitung mundur setiap 1 detik.

**Gap terhadap Apple Design:**
- Feedback harus kontinu *selama* interaksi, bukan hanya di akhir. Saat ini tombol hanya bereaksi saat ditekan; saat dilepaskan, tidak ada gerakan yang melengkapi sentuhan.
- `transition: transform 120ms` pada `.apple-press` adalah CSS transition dengan durasi tetap, bukan respons instan yang mengikuti jari.
- `alert()`, `confirm()`, `prompt()` native memblokir main thread dan merusak ilusi directness.

**Rekomendasi kode:**
```css
/* Ganti transition fixed dengan respons yang lebih segera pada sentuhan */
.apple-press {
  transition: transform 60ms cubic-bezier(0.2, 0, 0, 1), opacity 60ms ease;
  /* hapus transition pada properti yang diubah secara kontinu selama drag */
}
.apple-press:active {
  transform: scale(0.94);
  opacity: 0.92;
}
```
```js
// Ganti native alert/confirm dengan custom modal tak memblokir
appState.confirm = async (message) => {
  return new Promise((resolve) => {
    appState.openConfirmModal(message, resolve);
  });
};
```

---

### 4.2 Direct Manipulation — 1:1 Tracking

**Apa yang ada:**
- Tidak ada sama sekali. Semua navigasi adalah `onclick="appState.switchTab('...')"` yang mengganti `innerHTML` instan.
- Tombol navigasi bawah dan kartu kebiasaan hanya bereaksi pada klik; jari tidak dapat menarik, membuka, atau menutup panel searah dengan gerakan.
- `user-select: none` pada seluruh elemen (kecuali input/textarea) mencegah seleksi teks — agresif dan berkurangnya rasa kontrol pengguna.

**Gap terhadap Apple Design:**
- "Touch and content should move together." Tidak ada konten yang bergerak bersama jari.
- Tidak ada `setPointerCapture`, jadi jika jari keluar dari batas elemen saat menekan, tracking berhenti.
- Tidak ada grab offset (jari dapat menahan elemen di mana saja, tidak di-snap ke tengah paksa).

**Rekomendasi kode:**
```js
// Contoh: bottom sheet yang dapat ditarik turun/naik 1:1 dengan jari
let sheetY = 0;       // presentasi (live) value
let isDragging = false;
let startY, startSheetY;
const history = [];   // {y, t} untuk velocity

const sheet = document.querySelector('.bottom-sheet');

sheet.addEventListener('pointerdown', (e) => {
  sheet.setPointerCapture(e.pointerId);
  isDragging = true;
  startY = e.clientY;
  startSheetY = sheetY;
  history.length = 0;
  history.push({ y: e.clientY, t: performance.now() });
  sheet.style.willChange = 'transform';
}, { passive: false });

window.addEventListener('pointermove', (e) => {
  if (!isDragging) return;
  const dy = e.clientY - startY;
  sheetY = Math.max(0, startSheetY + dy);       // clamped di bawah layar
  sheet.style.transform = `translateY(${sheetY}px)`; // 1:1, dari presentasi
  history.push({ y: e.clientY, t: performance.now() });
  if (history.length > 6) history.shift();
}, { passive: false });

window.addEventListener('pointerup', (e) => {
  if (!isDragging) return;
  isDragging = false;
  sheet.releasePointerCapture(e.pointerId);
  const v = computeVelocity(history);           // px/s
  releaseSheet(v, sheetY);                      // lempar ke spring + snap
}, { passive: false });
```

---

### 4.3 Interruptibility (Inti dari Fluid Interface)

**Apa yang ada:**
- Tidak ada animasi yang dapat diinterupsi. `innerHTML` diganti total saat pindah tab atau membuka modal.
- Kelas `animate-in slide-in-from-bottom` dipakai di `openContextMenu` (baris 826) tetapi **tidak didefinisikan di CSS** — kelas mati, tidak ada gerakan.
- Ketika modal ditutup dan dibuka lagi, tidak ada "re-grab" dari nilai layar saat ini.

**Gap terhadap Apple Design:**
- Setiap animasi harus dapat di-grab dan dibalik saat tengah terbang.
- Tidak boleh mengunci input selama transition.
- Harus menganimasikan dari *presentation value* (nilai yang sedang terlihat di layar), bukan dari nilai target logis.

**Rekomendasi kode:**
```js
// Baca nilai transform yang sedang terlihat (presentation value) sebelum animasi baru
function getLiveY(el) {
  const style = window.getComputedStyle(el);
  const matrix = new WebKitCSSMatrix(style.transform || style.webkitTransform);
  return matrix.m42; // translateY live
}

// Spring dari nilai live, tidak dari target statis
animateSheetTo(targetY, { damping: 1, response: 0.3, velocity: currentVelocity });
```

---

### 4.4 Behavior over Animation — Use Springs

**Apa yang ada:**
- Nol spring. Semua gerakan pakai Tailwind transition:
  - Progress bar: `transition-all duration-500` / `duration-700`
  - Timer circle: `transition-all duration-1000 ease-linear`
  - Nav active state: `transition-colors`
- `apple-press` pakai `cubic-bezier(0.2, 0, 0, 1)` fixed 120ms.

**Gap terhadap Apple Design:**
- Apple mengganti triplet massa/kesiapan/redam dengan **damping ratio** + **response** (detik), bukan durasi fixed.
- Default UI harus critically damped (`damping 1.0`, `response 0.3–0.4s`), tanpa overshoot.
- Bounce hanya untuk interaksi yang membawa momentum (flick, throw), tidak untuk menu yang sekadar muncul.

**Rekomendasi kode (pakai library spring ringan, contoh Motion/Framer Motion atau custom):**
```js
import { animate } from 'motion'; // atau implementasi spring sendiri

// Default UI spring: critically damped, no overshoot
animate(el, { y: target }, { type: 'spring', bounce: 0, duration: 0.4 });

// Hanya untuk momentum (flick): sedikit bounce
animate(el, { y: target }, { type: 'spring', bounce: 0.2, duration: 0.4 });
```
Jika tidak ingin menambah dependensi, implementasikan spring sederhana (damping + response) yang mengubah `transform` via `requestAnimationFrame`, bukan `@keyframes` atau CSS transition.

---

### 4.5 Velocity Handoff & Momentum Projection

**Apa yang ada:**
- Tidak ada deteksi kecepatan jari. Tidak ada `pointermove` history, tidak ada `releaseVelocity`.

**Gap terhadap Apple Design:**
- Saat gestur berakhir, animasi harus melanjutkan pada kecepatan jari yang tepat (tidak ada jelas antara drag dan animasi).
- Flick harus di-proyeksikan ke titik istirahat (`current + project(v)`), lalu snap ke titik terdekat.

**Rekomendasi kode (fungsi proyeksi Apple):**
```js
function project(initialVelocity, decelerationRate = 0.998) {
  return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate);
}

function computeVelocity(history) {
  // historia terakhir ~100ms
  const now = performance.now();
  const recent = history.filter(h => now - h.t < 100);
  if (recent.length < 2) return 0;
  const dt = (recent[recent.length-1].t - recent[0].t) / 1000; // detik
  const dy = recent[recent.length-1].y - recent[0].y;
  return dy / dt; // px/s
}

// Saat jari dilepas:
const v = computeVelocity(history);
const projected = sheetY + project(v);
const target = nearestSnapPoint(projected); // 0 atau full-open
animateSheetTo(target, { velocity: v, damping: 0.8, response: 0.3 });
```

---

### 4.6 Spatial Consistency (Jalur Simetris & Origin)

**Apa yang ada:**
- Modal muncul dari bawah (`items-end justify-center`) tanpa jalur masuk/keluar yang simetris.
- Tidak ada `transform-origin` yang diancarkan pada elemen pemicu (trigger).
- Pindah tab mengganti seluruh konten tanpa gerakan spatial yang terhubung.

**Gap terhadap Apple Design:**
- Masuk dan keluar harus melalui jalur yang sama.
- Panel harus berasal dari elemen yang memicu (misal: popover skala dari tombol, tidak dari tengah).

**Rekomendasi kode:**
```css
.bottom-sheet {
  transform-origin: bottom center;
}
/* Masuk dan keluar dengan spring yang sama, hanya arah target yang berbeda */
```

---

### 4.7 Rubber-banding — Soft Boundaries

**Apa yang ada:**
- Tidak ada. Scroll konten berhenti keras di batas; tidak ada resistensi progresif.

**Gap terhadap Apple Design:**
- Di tekan tepi, elemen harus menahan progresif (semakin jauh melewati batas, semakin sedikit mengikuti jari), bukan berhenti kaku.

**Rekomendasi kode:**
```js
function rubberband(overshoot, dimension, constant = 0.55) {
  return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
}
// Terapkan pada sheetY saat melebihi batas atas/bawah saat drag
```

---

### 4.8 Gesture Design Details

**Apa yang ada:**
- Tap: `:active` scale ada (baik).
- Tidak ada hysteresis (~10px) untuk menentukan arah drag.
- Tidak ada cancel-by-dragging-away.
- `prompt()`, `alert()`, `confirm()` digunakan untuk input dan konfirmasi — blokir dan tak terpercaya secara haptis.
- Double-tap tidak ada (baik, tidak ada penundaan disambiguasi).

**Rekomendasi kode:**
- Tambahkan ambang gerak ~10px sebelum komitmen arah.
- Izinkan tarik-lurus-untuk-batal pada modal/tombol.
- Ganti `confirm('Yakin...')` dengan custom modal tactile (lihat 4.11).

---

### 4.9 Frame-Level Smoothness

**Apa yang ada:**
- `will-change` tidak dipakai.
- Animasinya pada `transform` dan `opacity` (composer-friendly) — baik.
- Re-render `innerHTML` paksa pada setiap perubahan state (baris 336, 352, 482, dll.) → layout thrashing, fokus hilang, layar berkedip.

**Rekomendasi kode:**
```css
.timer-circle, .bottom-sheet, .modal { will-change: transform; }
```
```js
// Hindari innerHTML total. Update hanya node yang berubah, atau gunakan
// morphing (mis. morphdom / morphdom-like) agar fokus dan state elemen preserved.
```

---

### 4.10 Materials & Depth (Translucency)

**Apa yang ada:**
- `.apple-glass`, `.apple-glass-gold`, `.apple-glass-dock` pakai `backdrop-filter: blur()` + semi-transparansi — ini adalah **poin terkuat** Sadar, sangat Apple.
- `border-top: 1px solid rgba(255,255,255,0.08)` pada dock — bright edge, bagus.
- Namun, container app (`shadow-2xl border-x`) adalah strip opak tetap; konten tidak scroll di bawah chrome (nav tetap di atas, bukan melayang di atas konten).

**Gap terhadap Apple Design:**
- Konten harus scroll di bawah toolbar/sheet translucent, bukan dipaksa ke dalam kotak tetap.
- Jangan tumpuk permukaan translucent ringan di atas translucent ringan (legibilitas runtuh).
- Scroll edge effect (fade/blur mask) di bawah sticky header, bukan border 1px kaku.

**Rekomendasi kode:**
```css
header, nav {
  position: sticky; /* atau fixed dengan z-index */
  backdrop-filter: blur(24px) saturate(190%);
}
/* Fade mask di tepi scroll konten yang bertemu chrome floating */
.main::after {
  content: '';
  position: absolute; bottom: 0; left: 0; right: 0; height: 40px;
  background: linear-gradient(transparent, #16161F);
  pointer-events: none;
}
```

---

### 4.11 Multimodal Feedback — Motion + Sound + Haptics

**Apa yang ada:**
- Tidak ada `navigator.vibrate` (haptik).
- Tidak ada nada/saat komitmen.
- Visual feedback ada tetapi tidak disinkronkan dengan sesama frame (karena tidak ada audio/haptik sama sekali).

**Rekomendasi kode:**
```js
function haptic(style = 'light') {
  if (navigator.vibrate) {
    navigator.vibrate(style === 'light' ? 10 : style === 'success' ? [10, 30, 10] : [40, 20, 40]);
  }
}
// Panggil pada saat: toggle selesai, snap modal, timer selesai, hapus kebiasaan
```
Kausalitas: haptik harus nyala pada event sebab (toggle membalik, item snap ke rumah), dan pada frame yang sama dengan visual.

---

### 4.12 Reduced Motion & Accessibility

**Apa yang ada:**
- Nol media query `prefers-reduced-motion`, `prefers-reduced-transparency`, `prefers-contrast`.
- `user-scalable=no, maximum-scale=1.0` dalam viewport — melarang zoom layar (berbahaya untuk aksesibilitas).
- Tidak ada `focus-visible` untuk navigasi keyboard.

**Rekomendasi kode:**
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
  .apple-press:active { transform: none; opacity: 0.8; }
}
@media (prefers-reduced-transparency: reduce) {
  .apple-glass, .apple-glass-dock { background: #16161F; backdrop-filter: none; }
}
```
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
```
Hapus `maximum-scale=1.0, user-scalable=no`.

---

### 4.13 Typography

**Apa yang ada:**
- Font: Plus Jakarta Sans (sans), Playfair Display / Instrument Serif (serif), JetBrains Mono (mono) — sistem font fallback ada.
- `tracking-[0.25em]` tetap pada logo SADAR (fixed tracking — salah untuk semua ukuran menurut Apple).
- Line-height sebagian besar default Tailwind; tidak ada optical sizing (`font-optical-sizing: auto` tidak diatur).
- Spacing dalam px, bukan rem/em — layout tidak skalakan bersama ukuran teks pengguna.

**Gap terhadap Apple Design:**
- Tracking harus spesifik ukuran: teks besar butuh negative tracking, teks kecil butuh positive tracking.
- Leading terbalik terhadap ukuran: tight pada heading, longgar pada body.
- Hierarchy dibangun dari weight + size + leading sekaligus, bukan size saja.

**Rekomendasi kode:**
```css
:root {
  font: 100%/1.5 system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  font-optical-sizing: auto;
}
.logo {
  font-size: clamp(1.5rem, 4vw, 2rem);
  line-height: 1.05;      /* tight leading untuk teks besar */
  letter-spacing: -0.02em; /* negative tracking saat tumbuh */
}
.body {
  font-size: 1rem;
  line-height: 1.6;       /* leading lebih longgar untuk body */
  letter-spacing: 0.01em; /* sedikit positif untuk teks kecil */
}
h1, h2, h3 { line-height: 1.15; letter-spacing: -0.01em; }
/* Spasi dalam rem agar skalakan dengan pengaturan teks pengguna */
section { padding: 1.5rem; gap: 1rem; }
```

---

### 4.14 Design Foundations (8 Prinsip Apple)

| Prinsip | Temuan Sadar |
|---------|--------------|
| Purpose | Jelas: pelacak kebiasaan tanpa tekanan streak. |
| Agency | Kurang: tidak ada undo, konfirmasi hanya native `confirm()`, tidak ada batal-gesture. |
| Responsibility | Privasi baik (localStorage), tapi tidak ada penanganan kekurangan/kesalahan yang halus. |
| Familiarity | Pola bottom sheet & tab nav familiar, tapi gerakan tidak sesuai fisika yang diharapkan. |
| Flexibility | Tetap mobile-first 430px, tidak mengadaptasi desktop dengan baik. |
| Simplicity | Antarmuka bersih, tapi re-render total membuatnya terasa "kasar". |
| Craft | Visual sudah rapi; motion dan detail interaksi belum. |
| Delight | Visual mencukupi, tapi belum ada motion yang membuat aplikasi "hidup". |

---

## 5. Daftar Temuan Kritis (Prioritas Tinggi)

| # | Masalah | Lokasi (baris) | Dampak Apple Design |
|---|---------|----------------|---------------------|
| 1 | Tidak ada spring; semua gerakan CSS transition fixed atau instan | Seluruh `<style>` & `transition-*` | Respons belum hidup, tidak interruptible |
| 2 | Tidak ada Pointer Events / drag / `setPointerCapture` | Seluruh JS | Tidak ada direct manipulation 1:1 |
| 3 | Tidak ada velocity handoff atau momentum projection | Tidak ada | Flick tidak terasa sebagai lemparan fisik |
| 4 | Re-render `innerHTML` total setiap state change | `render()`, `setHabitStatus`, dll. | Fokus hilang, berkedip, tidak halus |
| 5 | Kelas `animate-in slide-in-from-bottom` tidak didefinisikan CSS | Baris 826 | Efek modal mati, janji gerakan tidak tertemu |
| 6 | `user-scalable=no, maximum-scale=1.0` | Baris 5 | Melarang zoom (aksesibilitas) |
| 7 | Tidak ada `prefers-reduced-motion` / transparency / contrast | Tidak ada | Melanggar aksesibilitas Apple |
| 8 | Tidak ada haptik / nada | Tidak ada | Tidak ada feedback multimodal |
| 9 | `alert/confirm/prompt` native | Banyak | Memblokir main thread, merusak directness |
| 10 | Tracking tetap `tracking-[0.25em]` pada logo | Baris 108 | Fixed tracking salah untuk semua ukuran |
| 11 | Tombol navigasi 32×32 px (w-8 h-8) | Baris 112-146 | Di bawah target sentuhan 44px Apple |

---

## 6. Rekomendasi Perbaikan Kode Konkret (per File)

### 6.1 `public/index.html` — `<style>` (CSS)

Ganti blok `<style>` (baris 55–97) dengan versi yang mendukung spring-friendly, reduced motion, dan materi yang lebih baik:

```css
<style>
  /* --- Zero tap highlight & selection --- */
  * { -webkit-tap-highlight-color: transparent; }
  input, textarea { user-select: text; }
  :not(input):not(textarea) { user-select: none; }

  /* --- Tactile press: respons segera pada pointer-down --- */
  .apple-press {
    transition: transform 60ms cubic-bezier(0.2, 0, 0, 1), opacity 60ms ease;
    touch-action: manipulation;
  }
  .apple-press:active {
    transform: scale(0.94);
    opacity: 0.92;
  }

  /* --- Glass materials --- */
  .apple-glass {
    background: rgba(33, 33, 43, 0.78);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border: 1px solid rgba(255, 255, 255, 0.08);
  }
  .apple-glass-dock {
    background: rgba(22, 22, 31, 0.88);
    backdrop-filter: blur(24px) saturate(190%);
    -webkit-backdrop-filter: blur(24px) saturate(190%);
    border-top: 1px solid rgba(255, 255, 255, 0.08);
  }

  /* --- Scrollbars --- */
  .no-scrollbar::-webkit-scrollbar { display: none; }
  .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

  /* --- Reduced motion (Apple accessibility) --- */
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
    .apple-press:active { transform: none; opacity: 0.75; }
  }
  @media (prefers-reduced-transparency: reduce) {
    .apple-glass, .apple-glass-dock { background: #16161F !important; backdrop-filter: none !important; -webkit-backdrop-filter: none !important; }
  }

  /* --- Typography (optical sizing, size-specific tracking) --- */
  :root {
    font: 100%/1.5 system-ui, -apple-system, BlinkMacSystemFont, 'Plus Jakarta Sans', sans-serif;
    font-optical-sizing: auto;
  }
  .text-display { line-height: 1.05; letter-spacing: -0.02em; }
  .text-body { line-height: 1.6; letter-spacing: 0.01em; }
  .text-small { line-height: 1.4; letter-spacing: 0.02em; }

  /* --- Compositor hint for moving elements --- */
  .will-move { will-change: transform; }
</style>
```

### 6.2 `public/index.html` — `<script>` (JavaScript)

Tambahkan modul spring minimal dan gestur bottom sheet. Contoh penambahan di dalam `AppStateStore` (atau sebagai modul terpisah yang di-import via `<script type="module">`):

```js
// ── Spring engine (damping + response, Apple style) ──
function springTo(target, { damping = 1, response = 0.35, velocity = 0, onUpdate, onEnd }) {
  // Kritically damped spring solver sederhana (frame-based via rAF)
  let current = parseFloat(getComputedStyle(onUpdate.el).transform) ?? 0; // presentation value
  let v = velocity;
  const eps = 0.01;
  let raf;

  function loop(t) {
    // spring physics (damping ratio + response) → transform ke target
    const zeta = damping;
    const omega = 2 * Math.PI / response; // penyederhanaan untuk ilustrasi
    const dt = 1 / 60;
    const a = -(2 * zeta * omega * v) - (omega * omega * (current - target));
    v += a * dt;
    current += v * dt;
    onUpdate(current);
    if (Math.abs(v) < eps && Math.abs(current - target) < eps) {
      onUpdate(target);
      onEnd?.();
      return;
    }
    raf = requestAnimationFrame(loop);
  }
  raf = requestAnimationFrame(loop);
  return () => cancelAnimationFrame(raf); // cancel = interruptible
}

// ── Gestur bottom sheet 1:1 + velocity handoff ──
function initBottomSheet(sheetEl) {
  let y = 0, isDrag = false, startY, startSheetY, history = [], cancelSpring;
  sheetEl.style.touchAction = 'none';
  sheetEl.setPointerCapture = sheetEl.setPointerCapture || function(){};

  sheetEl.addEventListener('pointerdown', (e) => {
    sheetEl.setPointerCapture(e.pointerId);
    isDrag = true; startY = e.clientY; startSheetY = y; history = [];
    history.push({ y: e.clientY, t: performance.now() });
    if (cancelSpring) cancelSpring();
    sheetEl.classList.add('will-move');
  });

  window.addEventListener('pointermove', (e) => {
    if (!isDrag) return;
    const dy = e.clientY - startY;
    y = Math.max(0, startSheetY + dy);
    sheetEl.style.transform = `translateY(${y}px)`;
    history.push({ y: e.clientY, t: performance.now() });
    if (history.length > 6) history.shift();
  }, { passive: false });

  window.addEventListener('pointerup', (e) => {
    if (!isDrag) return;
    isDrag = false;
    sheetEl.releasePointerCapture(e.pointerId);
    const v = computeVelocity(history);
    const projected = y + projectVelocity(v);
    const target = projected < 40 ? 0 : fullOpenY; // snap ke titik terdekat
    cancelSpring = springTo(target, {
      damping: 0.8, response: 0.35, velocity: v,
      onUpdate: (val) => { y = val; sheetEl.style.transform = `translateY(${val}px)`; },
      onEnd: () => { sheetEl.classList.remove('will-move'); }
    });
  }, { passive: false });
}

function computeVelocity(history) {
  const now = performance.now();
  const recent = history.filter(h => now - h.t < 100);
  if (recent.length < 2) return 0;
  const dt = (recent[recent.length-1].t - recent[0].t) / 1000;
  return (recent[recent.length-1].y - recent[0].y) / dt;
}
function projectVelocity(v, d = 0.998) {
  return (v / 1000) * d / (1 - d);
}
```

Ganti setiap `confirm()` / `alert()` / `prompt()` dengan custom modal non-blokir (contoh `appState.openConfirmModal(message, onResolve)`).

### 6.3 Penggantian `innerHTML` total (render engine)

Ganti pola:
```js
container.innerHTML = this.renderTodayView();
```
dengan pembalikan node yang lebih halus (morphdom / diff minimal) atau setidaknya jaga elemen fokus dan hindari rebuild DOM yang tidak perlu saat tab sama.

### 6.4 Viewport (aksesibilitas)

Ubah baris 5:
```html
<!-- Sebelum -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover" />
<!-- Sesudah -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
```

---

## 7. Prioritas Implementasi

| Prioritas | Aksi | Estimasi |
|-----------|------|----------|
| P1 | Hapus `user-scalable=no`, tambahkan `prefers-reduced-motion` / transparency / contrast | 1 jam |
| P1 | Ganti `alert/confirm/prompt` dengan custom modal tactile | 2 jam |
| P1 | Aktifkan `will-change: transform` pada elemen bergerak; atur ukuran target sentuhan ≥44px | 1 jam |
| P2 | Tambah engine spring + gestur bottom sheet (Pointer Events, `setPointerCapture`, velocity handoff, projection, rubber-banding) | 6–8 jam |
| P2 | Ganti CSS transition fixed durasi pada progress bar & timer dengan spring | 2 jam |
| P2 | Perbaiki kelas mati `animate-in slide-in-from-bottom` atau hapus | 30 menit |
| P3 | Typography: optical sizing, size-specific tracking/leading, spacing rem/em | 2 jam |
| P3 | Haptik (Vibration API) pada komitmen & snap | 1 jam |
| P4 | Incremental DOM render (mengganti `innerHTML` total) | 4–6 jam |

---

## 8. Contoh Implementasi Siap Pakai (Modal Bottom Sheet dengan Spring)

```html
<!-- Di dalam modal-container, saat membuka bottom sheet -->
<div class="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-end justify-center" id="sheet-backdrop">
  <div id="sheet" class="w-full max-w-[430px] apple-glass rounded-t-3xl p-5 border-t border-surfaceBorder will-move" style="transform: translateY(0)">
    <!-- isi modal -->
  </div>
</div>
```

```js
// Panggil initBottomSheet(document.getElementById('sheet')) setelah modal di-render.
// Sheet mengikuti jari 1:1, dilepaskan → meluncur dengan spring ke posisi terbuka/tertutup,
// dapat di-grab kembali saat tengah terbang (interruptible), dan getaran ringan saat snap ke rumah.
```

---

## 9. Kesimpulan

Sadar sudah punyi **visual bahasa Apple** (dark mode, kaca blur, aksen emas, tipografi bermuatan) tetapi belum memiliki **jiwa antarmuka fluid Apple**. Gerakan saat ini adalah transisi statis dengan durasi tetap, tanpa spring, tanpa gestur jari, tanpa velocity, dan tidak dapat diinterupsi. Dengan menerapkan rekomendasi di atas — terutama engine spring berdasarkan damping/response, gestur Pointer Events dengan velocity handoff dan momentum projection, reduced media query, serta haptik — Sadar dapat berubah dari "halaman yang diganti isinya" menjadi "objek fisik yang Responsif, langsung dapat ditangani, dan nyaman disentuh" sesuai filosofi *Designing Fluid Interfaces*.

Semua perubahan direkomendasikan dilakukan pada `public/index.html` danディ孵 đồngokes pada salinan identik di root dan `web_app/`.

---
*Laporan ini dihasilkan menggunakan skill `apple-design` (`~/.opencode/skills/apple-design/SKILL.md`) sebagai referensi evaluasi antarmuka fluid web.*