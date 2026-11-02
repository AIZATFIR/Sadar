# Sadar Autonomous Evolution Roadmap

### Sprint Architecture Review — 2026-11-02 20:47
- Active Modules: awareness_mindfulness
- Pending Uncommitted Changes: 5 files
- Target: High reliability, zero bloat, native responsive performance.

### Sprint Architecture Review — 2026-11-02 20:52
- Active Modules: awareness_mindfulness
- Pending Uncommitted Changes: 0 files
- Target: High reliability, zero bloat, native responsive performance.

### Sprint Architecture Review — 2026-11-02 20:58
- Active Modules: awareness_mindfulness
- Pending Uncommitted Changes: 0 files
- Target: High reliability, zero bloat, native responsive performance.


### Cycle #1 Directive (2026-11-02 21:06)
```css
/* 1. Auto-growing mindful entry without JS */
.journal-input {
  field-sizing: content;
  min-height: 2.5lh;
  max-height: 45vh;
  width: 100%;
  resize: none;
  line-height: 1.6;
  border: none;
  outline: none;
  background: transparent;
  font-family: inherit;
}

/* 2. Precision vertical alignment & tabular stream */
.log-stream {
  display: grid;
  grid-template-columns: [time] 4.5rem [content] 1fr;
  row-gap: 1.25lh;
}

.log-entry {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / -1;
  align-items: baseline;
}

.log-time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--fg-subtle, #8a857b);
}

/* 3. Zero-JS sticky rhythm delimiter */
.log-group-header {
  position: sticky;
  top: 0;
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  padding-block: 0.5lh;
  grid-column: 1 / -1;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  color: var(--fg-muted, #a09a8e);
}
```

skipped: JS resize listeners and date stickiness observers; add JS only if supporting Safari < 17.4 or legacy Chromium.
skipped: Rich text editor toolbar abstractions; add when users demand formatted markdown over raw thought capture.
skipped: Infinite scroll pagination component; add when client performance degrades past 500 visible entries.


### Cycle #1 Directive (2026-11-02 21:09)
### 1. Auto-Expanding Conscious Log Input (Drop JS resize handlers)
```css
/* sadar-input.css */
textarea.log-entry {
  field-sizing: content; /* ponytail: native auto-resize; fallback is min-height */
  min-height: 2.5lh;
  max-height: 18lh;
  line-height: 1.6;
  padding: 0.5lh 0;
  border: none;
  border-bottom: 1px solid var(--border-subtle, #e5e5e5);
  resize: none;
  outline: none;
  background: transparent;
  font-family: inherit;
}
```
→ skipped: JS height recalculation listeners, add when Safari < 17.4 support is strictly required.

---

### 2. Optical Vertical Rhythm & Metacognitive Log Timeline
```css
/* sadar-timeline.css */
.log-stream {
  display: flex;
  flex-direction: column;
  padding-left: 1rem;
  border-left: 1px solid var(--line-subtle, #f0ede8);
  gap: 1.5lh;
}

.log-item {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  align-items: first baseline; /* optical alignment between timestamp and thought */
  column-gap: 1.25rem;
}

.log-item time {
  font-feature-settings: "tnum";
  font-size: 0.8125rem;
  color: var(--text-tertiary, #8e8e93);
}
```
→ skipped: Nested bullet/connector SVG wrappers, add when tree-branching sub-logs are implemented.

---

### 3. Native Keyboard-First Submission (Zero-bloat capture)
```html
<!-- sadar-quick-entry.html -->
<form method="dialog" class="entry-box" onkeydown="if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();this.requestSubmit();}">
  <textarea class="log-entry" name="metacognition" placeholder="Observe current state..." required></textarea>
</form>
```
→ skipped: Custom hotkey dispatchers and shortcut libraries, add when multiple modifier key chords are needed.


### Cycle #1 Directive (2026-11-02 21:12)
```css
/* 1. Native auto-expanding log entry without JS */
textarea.log-input {
  field-sizing: content;
  min-height: 3lh;
  max-height: 35vh;
  line-height: 1.6;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  resize: none;
  /* ponytail: field-sizing relies on modern Chromium/Safari; upgrade to minimal JS if legacy support needed */
}

/* 2. Strict optical vertical rhythm */
.journal-stream {
  display: flex;
  flex-direction: column;
  row-gap: 2lh;
  max-width: 65ch;
  margin-inline: auto;
  margin-block: 3lh;
}

/* 3. Baseline-aligned micro-entry stream */
.log-item {
  display: grid;
  grid-template-columns: 3.5rem 1fr;
  column-gap: 1.25rem;
  align-items: baseline;
}

.log-item time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--color-muted, #86868b);
}

.log-item p {
  margin: 0;
  line-height: 1.6;
}
```

```html
<section class="journal-stream">
  <textarea class="log-input" placeholder="Observe without judging..."></textarea>
  <article class="log-item">
    <time>07:15</time>
    <p>Noticed shallow breathing before checking email. Paused for three cycles.</p>
  </article>
</section>
```

skipped: JS-based autosize libraries, complex timeline wrapper DOM, custom date parsing.  
add when: supporting legacy browsers without `field-sizing`, or grouping logs across multi-day calendar boundaries.


### Cycle #2 Directive (2026-11-02 21:17)
### 1. Optical Baseline Alignment for Log Entries
Align timestamps and conscious thoughts to the typography baseline instead of flex-center approximations, locking vertical rhythm.

```css
.log-stream {
  list-style: none;
  padding-left: 1.25rem;
  border-left: 1px solid color-mix(in srgb, currentColor 10%, transparent);
}

.log-entry {
  display: grid;
  grid-template-columns: 4.5ch 1fr;
  align-items: baseline;
  gap: 1rem;
  padding: 0.5rem 0;
  scroll-margin-block: 2rem;
}

.log-time {
  font-size: 0.75rem;
  font-variant-numeric: tabular-nums;
  opacity: 0.4;
}
```
* Skipped: Custom timeline component, icon glyphs, absolute-positioned decorative rail dots.
* Add when: User requests multi-track concurrent event logs or rich tag filters.

---

### 2. Zero-JS Fluid Note Composer
Eliminates resize observers, auto-grow JavaScript bundles, and box borders for raw thought capture.

```html
<textarea
  id="quick-capture"
  class="zen-capture"
  placeholder="Observe thought..."
  rows="1"
  maxlength="1000"
></textarea>
```

```css
.zen-capture {
  width: 100%;
  field-sizing: content; /* ponytail: native in Chromium/Safari 18.2+; degrades to 1-line scroll in older engines */
  min-height: 1.6lh;
  max-height: 12lh;
  resize: none;
  border: 0;
  outline: none;
  background: transparent;
  line-height: 1.6;
  font-family: inherit;
  color: inherit;
}
```
* Skipped: `textarea` scroll-height resize loops, Markdown live previewers, rich-text toolbars.
* Add when: Logs require multi-block rich media or block embeds.

---

### 3. Native Metacognition Log Persistence & Rollback
Atomic append directly against `localStorage` with corrupted-state defense.

```js
export const logStore = {
  get: () => {
    try { return JSON.parse(localStorage.getItem('sadar_logs') || '[]'); }
    catch { return []; }
  },
  append: (text) => {
    const clean = text?.trim();
    if (!clean) return null;
    const entry = { id: crypto.randomUUID(), t: Date.now(), b: clean };
    const logs = [...logStore.get(), entry];
    localStorage.setItem('sadar_logs', JSON.stringify(logs));
    return entry;
  }
};

// Self-check
console.assert(logStore.append(" ") === null, "Rejects blank logs");
console.assert(logStore.append("Breath awareness")?.b === "Breath awareness", "Appends valid log");
```
* Skipped: IndexedDB wrappers, Redux/Zustand state slices, remote sync orchestration.
* Add when: Storage exceeds 5MB or multi-device sync is explicitly scheduled.


### Cycle #3 Directive (2026-11-02 21:23)
### 1. Auto-Expanding Conscious Entry (Native CSS, zero JS)

```css
/* Replace JS textarea autoresize logic */
.journal-input {
  field-sizing: content;
  min-height: 2lh;
  line-height: 1.6;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  width: 100%;
}
```
skipped: ResizeObserver/JS height recalculation, add when: legacy browser support (< Chrome 123 / Safari 18.2) is mandatory.

---

### 2. Optical Baseline Alignment for Log Entries

```css
/* Precise vertical sync between timestamp and reflection */
.log-row {
  display: grid;
  grid-template-columns: 4.5ch 1fr;
  align-items: first baseline;
  column-gap: 1.25rem;
  padding-block: 0.5lh;
  /* ponytail: margin-trim handles container bounds without :last-child hacks */
  margin-trim: block;
}

.log-row time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--color-subtle, #8a8580);
}
```
skipped: Flexbox vertical centering and manual padding tweaks, add when: rows contain multi-line tags beside the timestamp.

---

### 3. Ambient Writing Mode (CSS Native Focus-dimming)

```css
/* Dims historical noise during active introspection */
.log-stream:has(.journal-input:focus) .log-row {
  opacity: 0.35;
  transition: opacity 180ms ease-out;
}

.log-stream .log-row:focus-within {
  opacity: 1;
}
```
skipped: Focus state management in React/Svelte stores, add when: log entries require rich inline action toolbars.


### Cycle #4 Directive (2026-11-02 21:28)
### 1. Zero-JS Auto-Expanding Conscious Input

```css
/* Replace JS textarea resize observers */
.journal-input {
  field-sizing: content;
  min-height: 3lh;
  max-height: 30lh;
  width: 100%;
  resize: none;
  border: 0;
  outline: none;
  background: transparent;
  line-height: 1.65;
  font-family: inherit;
}
```
skipped: ResizeObserver/input listener script.  
add when: Legacy Safari (<17.4) polyfill is strictly required.

---

### 2. Zen Optical Column & Vertical Alignment

```css
/* Enforce strict vertical rhythm and 42ch reading width */
.journal-canvas {
  display: grid;
  grid-template-columns: minmax(0, 42ch);
  justify-content: center;
  align-content: start;
  min-height: 100svh;
  padding-block: clamp(3rem, 8svh, 6rem);
  row-gap: 2.75rem;
}
```
skipped: Flexbox spacers, calc wrappers, and media-query height ladders.  
add when: Supporting multi-pane or side-by-side split screens.

---

### 3. Baseline-Aligned Semantic Log Entry

```html
<!-- Flat DOM for conscious living stream -->
<li class="log-entry">
  <time datetime="2025-05-14T06:30">06:30</time>
  <p>Awareness settled. Reduced noise before first action.</p>
</li>
```
```css
.log-entry {
  display: grid;
  grid-template-columns: 4.5ch 1fr;
  column-gap: 1.25rem;
  align-items: baseline;
}
.log-entry time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: color-mix(in srgb, currentColor 45%, transparent);
}
```
skipped: Nested flex badge wrappers and pill containers.  
add when: Interactive filter tags or edit menus are bound directly to the timestamp.


### Cycle #5 Directive (2026-11-02 21:34)
### 1. Baseline Vertical Rhythm for Log Stream

```css
.journal-stream {
  display: flex;
  flex-direction: column;
}

.log-entry {
  display: grid;
  grid-template-columns: 4rem 1fr;
  align-items: baseline;
  column-gap: 1.25rem;
  padding-block: 0.625rem;
  border-inline-start: 1px solid var(--zen-border, rgba(0, 0, 0, 0.08));
  padding-inline-start: 1rem;
}

.log-entry time {
  font-variant-numeric: tabular-nums;
  font-size: 0.75rem;
  color: var(--zen-muted, #8e8e93);
}

.log-entry p {
  margin: 0;
  line-height: 1.5;
  color: var(--zen-text, #1c1c1e);
}
```
→ skipped: JS timestamp formatters and custom timeline rail graphics.  
→ add when: multi-day grouping or time-zone conversions are explicitly required.

---

### 2. Auto-Expanding Conscious Input (Native CSS)

```css
/* ponytail: field-sizing covers modern browsers; upgrade with fallback if legacy Safari support is requested */
textarea.conscious-log {
  field-sizing: content;
  min-height: 2lh;
  line-height: 1.6;
  resize: none;
  border: 0;
  padding: 0;
  background: transparent;
  font-family: inherit;
  outline: none;
  width: 100%;
}
```
→ skipped: `resize` event listeners, auto-grow height recalculation scripts, and hidden ghost `div` measuring hacks.  
→ add when: target environment mandates Safari < 17.4.

---

### 3. Streamlined Enter-to-Log Keyboard Binding

```js
// ponytail: single-key dispatch ceiling; upgrade to Cmd+Enter when long-form essaying is introduced
document.querySelector("#conscious-form")?.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && !e.shiftKey) {
    e.preventDefault();
    e.currentTarget.requestSubmit();
  }
});
```
→ skipped: UI submit buttons, custom hotkey libraries, and debounced input managers.  
→ add when: rich text / multi-paragraph Markdown formatting is added.


### Cycle #6 Directive (2026-11-02 21:40)
### 1. Frictionless Stream-of-Consciousness Input (Zero-JS Auto-Resize)

```css
/* Replace fixed textareas/JS auto-resizers */
.conscious-log-input {
  inline-size: 100%;
  field-sizing: content; /* ponytail: native auto-expand; fallback is standard 3-row textarea */
  min-block-size: 3lh;
  max-block-size: 45vh;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  font-family: inherit;
  font-size: 1.0625rem;
  line-height: 1.6;
  color: var(--zen-fg, #2c2825);
}
```
`[code] → skipped: [JS textarea autosize listeners], add when [browsers lacking field-sizing support become hard requirement].`

---

### 2. Baseline-Snapped Vertical Alignment for Logs

```css
/* Eliminates vertical alignment wobble between timestamp and text */
.log-row {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  column-gap: 1.25rem;
  align-items: first baseline;
  padding-block: 0.625rem;
}

.log-time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--zen-muted, #8c827a);
  user-select: none;
}

.log-body {
  font-size: 1rem;
  line-height: 1.5;
  color: var(--zen-fg, #2c2825);
  margin: 0;
}
```
`[code] → skipped: [flexbox vertical-offset magic margins], add when [columns require multi-tier metadata blocks].`

---

### 3. Streamlined Center Spine Layout

```css
/* Single column constraint for warm, distraction-free focus */
.sadar-canvas {
  max-inline-size: 62ch;
  margin-inline: auto;
  padding-inline: 1.5rem;
  padding-block: clamp(3rem, 10vh, 7rem);
  display: flex;
  flex-direction: column;
  row-gap: 2.5rem;
}
```
`[code] → skipped: [sidebar/dashboard grid shells], add when [dense analytics/history search is explicitly required].`


### Cycle #7 Directive (2026-11-02 21:46)
### 1. Vertical Rhythm: Baseline-Aligned Stream

```css
.log-stream {
  display: grid;
  grid-template-columns: auto 1fr;
  column-gap: 1.25rem;
  row-gap: 1.5lh;
  align-items: baseline;
}

.log-stream time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--text-muted, #8a8178);
  white-space: nowrap;
}

.log-stream .entry-content {
  margin: 0;
  line-height: 1.6;
}
```
skipped: Flexbox margins & multi-column wrapping logic; add when logs support inline media attachments.

---

### 2. Streamlined Log Capture: Native Auto-Grow

```css
.entry-field {
  field-sizing: content; /* ponytail: modern baseline; upgrade with JS scrollHeight calc only if Firefox ESR support is mandatory */
  width: 100%;
  min-height: 1.6lh;
  max-height: 15lh;
  resize: none;
  line-height: 1.6;
  border: none;
  background: transparent;
  outline: none;
}
```
skipped: `resize` event listeners and hidden dummy `div` synchronizers; add when older Gecko-engine telemetry demands it.

---

### 3. Conscious Log Separators: Native Semantic Anchors

```html
<ol class="log-stream">
  <time datetime="2024-10-24T08:30">08:30</time>
  <div class="entry-content">Noticing attachment to today's shipping velocity. Dropped the tension.</div>

  <time datetime="2024-10-24T12:15">12:15</time>
  <div class="entry-content">Energy dip post-prandial. 10m breath awareness before code review.</div>
</ol>
```
skipped: Date grouping wrappers and card-container UI bloat; add when aggregate multi-day search and pagination become active requirements.


### Cycle #8 Directive (2026-11-02 21:52)
### 1. Optical Timeline Rhythm (Zero-DOM hairline connector)

```css
/* Replaces wrapper divs and icon offset hacks */
.log-stream {
  display: grid;
  grid-template-columns: 4rem 1px minmax(0, 1fr);
  column-gap: 1.5rem;
  row-gap: 2rem;
  align-items: baseline;
}

.log-stream::before {
  content: "";
  grid-column: 2;
  grid-row: 1 / -1;
  background: var(--hairline, color-mix(in srgb, currentColor 8%, transparent));
}

.log-time {
  font-variant-numeric: tabular-nums;
  font-size: 0.75rem;
  color: var(--text-muted);
}
```
→ skipped: complex SVGs and nested container elements.  
→ add when: multi-day branch histories require distinct vertical node forks.

---

### 2. Auto-Expanding Reflection Input (Zero-JS)

```css
/* Drops scrollbars and jumpy JS height-listeners */
.metacognition-entry {
  field-sizing: content;
  min-height: 4lh;
  line-height: 1.65;
  width: 100%;
  border: 0;
  outline: 0;
  background: transparent;
  resize: none;
  /* ponytail: relies on Chromium 123+ and Safari 18.2+. Add manual scroll listener if targeting legacy engines. */
}
```
→ skipped: `textarea.style.height = scrollHeight + 'px'` JS sync loops.  
→ add when: legacy browser targets fall below baseline compatibility.

---

### 3. Chronological Day Grouping (Stdlib ES2024)

```js
// Native grouping: eliminates date-fns/lodash
const entriesByDate = Object.groupBy(entries, (entry) =>
  new Date(entry.createdAt).toLocaleDateString("en-CA") // YYYY-MM-DD
);

// Self-check
console.assert(
  Object.keys(Object.groupBy([{ t: 0 }], () => "1970-01-01"))[0] === "1970-01-01",
  "groupBy failed"
);
```
→ skipped: external temporal/date grouping libraries.  
→ add when: localized dynamic calendar systems (e.g., Hijri) are strictly required in the model layer.


### Cycle #9 Directive (2026-11-02 21:57)
### 1. Frictionless Conscious Entry Input

Eliminates auto-resize JS dependencies using native CSS.

```css
.log-input {
  width: 100%;
  field-sizing: content;
  min-height: 1.5lh;
  max-height: 10lh;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  line-height: 1.6;
  font-family: inherit;
  /* ponytail: relies on CSS field-sizing (Chromium 123+, Safari 18+); upgrade to 3-line scrollHeight sync if legacy support needed */
}
```
→ skipped: [Auto-resize JS libraries/event listeners], add when [strict support for legacy browsers is explicitly required].

---

### 2. Optical Vertical Rhythm & Tabular Baseline

Locks conscious logs to a natural vertical reading tempo (`lh`) with stable numeric alignment.

```css
.journal-stream {
  display: flex;
  flex-direction: column;
  row-gap: 1.25lh;
  max-inline-size: 62ch;
  margin-inline: auto;
  text-wrap: pretty;
}

.log-meta {
  display: flex;
  align-items: baseline;
  gap: 1.5ch;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.01em;
}

.log-meta time {
  font-size: 0.8125rem;
  color: color-mix(in srgb, currentColor 55%, transparent);
}
```
→ skipped: [Complex baseline grid math/fixed-height divs], add when [multi-column dense dashboard view is built].

---

### 3. Streamlined Expandable Reflection Row

Native semantic disclosure without UI state management.

```html
<details class="reflection-node">
  <summary class="log-meta">
    <time datetime="2025-05-18T14:30">14:30</time>
    <span>Overstimulated by task switching; returning to breath.</span>
  </summary>
  <div class="reflection-body">
    <p>Trigger: 4 open projects. Shift: 5-minute single-focus reset.</p>
  </div>
</details>
```

```css
.reflection-node summary {
  list-style: none;
  cursor: pointer;
}
.reflection-node summary::-webkit-details-marker { display: none; }
.reflection-body {
  padding-inline-start: calc(6ch + 1.5ch); /* align beneath summary text, past timestamp */
  margin-block-start: 0.5lh;
  opacity: 0.85;
}
```
→ skipped: [Accordion toggle libraries and animated collapse state], add when [animated micro-interactions are scheduled for polish].


### Cycle #10 Directive (2026-11-02 22:03)
### 1. Baseline-Aligned Vertical Timeline

```css
.log-stream {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  row-gap: 1.5lh;
  align-items: baseline; /* Locks timestamp baselines to entry text */
}

.log-stream time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--zen-muted, #7c7c80);
}
```
skipped: custom SVG connector rails and node dots; add when non-linear thread branching is requested.

---

### 2. Zero-JS Frictionless Thought Capture

```css
.thought-capture {
  field-sizing: content; /* ponytail: native auto-expand; fallback requires resize observer */
  min-height: 1.5lh;
  max-height: 18lh;
  width: 100%;
  resize: none;
  border: 0;
  outline: 0;
  font: inherit;
  background: transparent;
  line-height: 1.6;
}
```
skipped: textarea auto-grow JS event listeners; add when supporting Safari < 17.4 or legacy webviews.

---

### 3. Native Exclusive Log Folding

```html
<details name="daily-log" class="day-fold" open>
  <summary class="select-none font-medium text-sm tracking-tight cursor-pointer">
    Today
  </summary>
  <div class="log-stream mt-3">
    <time datetime="2025-05-18T08:30">08:30</time>
    <p>Morning awareness: breath settled, mind clear.</p>
  </div>
</details>
```
skipped: animated JS accordion manager; add when fluid height interpolation via `@starting-style` is budgeted.


### Cycle #11 Directive (2026-11-02 22:09)
### 1. Zero-JS Dynamic Canvas & Baseline Rhythm

```css
/* Optical baseline alignment and native expanding input */
.journal-canvas {
  display: grid;
  gap: 1.5lh;
  max-width: 62ch;
  margin-inline: auto;
  padding-block: 6lh 4lh;
}

.journal-input {
  field-sizing: content;
  min-height: 2lh;
  line-height: 1.65;
  border: none;
  outline: none;
  resize: none;
  background: transparent;
  font-family: inherit;
  font-size: 1.05rem;
  color: var(--text-primary, oklch(0.2 0.01 45));
}
```
→ skipped: JS-based autosize listeners and wrappers, add when: legacy browser support (< Safari 17.4) is explicitly required.

---

### 2. Conscious Living Stream (Zen Spine & Aligned Nodes)

```css
/* Monolithic timeline spine aligned precisely to text cap-height */
.conscious-stream {
  list-style: none;
  padding-inline-start: 1.25rem;
  border-inline-start: 1px solid var(--spine, oklch(0.88 0.01 50));
  display: flex;
  flex-direction: column;
  gap: 2lh;
}

.conscious-stream > li {
  position: relative;
  line-height: 1.5;
}

.conscious-stream > li::before {
  content: "";
  position: absolute;
  inset-inline-start: calc(-1.25rem - 3.5px);
  inset-block-start: 0.45lh;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--dot, oklch(0.6 0.03 45));
}
```
→ skipped: SVG track components and complex flex-alignment wrappers, add when: branching logs or non-linear timeline paths are introduced.

---

### 3. Flat Fast-Capture Storage

```typescript
// ponytail: Synchronous LocalStorage ceiling ~5MB; swap to SQLite/WASM if entries exceed 5,000
export type ConsciousLog = { t: number; impulse: string; witness: string };

export const logStore = {
  add: (log: Omit<ConsciousLog, "t">): ConsciousLog => {
    const entry: ConsciousLog = { t: Date.now(), ...log };
    const list: ConsciousLog[] = JSON.parse(localStorage.getItem("sadar_stream") || "[]");
    localStorage.setItem("sadar_stream", JSON.stringify([entry, ...list]));
    return entry;
  }
};

// Self-check
console.assert(logStore.add({ impulse: "rushing", witness: "felt tight chest" }).t > 0);
```
→ skipped: State machines, validation libraries, and ORM abstractions, add when: background cloud synchronization is actively provisioned.


### Cycle #12 Directive (2026-11-02 22:14)
### 1. Native Auto-Growing Journal Input (Drop JS resize handlers)

```css
/* sadar-input.css */
.journal-entry-input {
  field-sizing: content; /* ponytail: evergreen browsers only; fallback to min-height */
  min-height: 3lh;
  line-height: 1.6;
  width: 100%;
  resize: none;
  background: transparent;
  border: 0;
  outline: none;
  font-family: inherit;
}
```
skipped: ResizeObserver/JS height calculation scripts.  
add when: Firefox-without-flag support becomes a strict requirement.

---

### 2. Tabular Baseline Grid for Conscious Living Logs

```css
/* sadar-timeline.css */
.log-stream {
  display: grid;
  grid-template-columns: [time] 4.5rem [entry] 1fr;
  row-gap: 0.75lh;
  column-gap: 1.5rem;
  align-items: baseline;
}

.log-stream time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--color-stone-muted, #8a8886);
}
```
skipped: Flexbox margins, negative offsets, and manual alignment hacks.  
add when: Multi-column metadata (tags, states) exceeds two track definitions.

---

### 3. Zero-JS Instant Local Draft Recovery

```html
<!-- index.html -->
<form id="journal-form" oninput="localStorage.setItem('sadar_draft', this.entry.value)">
  <textarea name="entry" class="journal-entry-input" placeholder="Observe without judging..."></textarea>
</form>
<script>
  journalForm = document.getElementById('journal-form');
  journalForm.entry.value = localStorage.getItem('sadar_draft') || '';
</script>
```
skipped: Debounce utilities, storage wrappers, and mutation frameworks.  
add when: Draft payload size causes main-thread frame drops (unlikely for plain text).


### Cycle #13 Directive (2026-11-02 22:20)
### 1. Zero-JS Auto-Expanding Log Field

```css
/* Replaces JS textarea auto-grow listeners */
.log-input {
  field-sizing: content;
  min-height: 1.5lh;
  max-height: 20lh;
  line-height: 1.5;
  font-family: inherit;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  width: 100%;
}
```
skipped: JS scrollHeight recalculation and ResizeObserver boilerplate.  
add when: Supporting browsers without CSS `field-sizing` (Chromium <123, Safari <18.2).

---

### 2. Baseline-Locked Timeline Grid

```css
/* Optical baseline vertical alignment for conscious logs */
.log-stream {
  display: grid;
  grid-template-columns: 5ch 1fr;
  column-gap: 1.5ch;
  row-gap: 0.75lh;
  align-items: baseline;
}

.log-time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  line-height: 1.5;
  color: var(--muted, #737373);
  user-select: none;
}

.log-content {
  line-height: 1.5;
  margin: 0;
}
```
skipped: Margin-hack timeline spacing and decorative absolute-positioned timeline lines.  
add when: Multi-dimensional log metadata (mood, tags, coordinates) demands `subgrid`.

---

### 3. Native Frictionless Entry Submission

```js
// ponytail: desktop-only shortcut; upgrade path adds mobile swipe-to-commit gesture
document.querySelector('#log-form textarea')?.addEventListener('keydown', (e) => {
  if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
    e.preventDefault();
    e.currentTarget.form?.requestSubmit();
  }
});
```
skipped: Hotkey managers, rich-text markdown libraries, bespoke validation managers.  
add when: Sadar gains a global Command-K palette.


### Cycle #14 Directive (2026-11-02 22:26)
### 1. Frictionless Auto-Growing Journal Input (CSS Native)

```css
/* Replace JS auto-resize hacks with native CSS */
.log-input {
  field-sizing: content;
  min-height: 1.6lh;
  max-height: 12lh;
  line-height: 1.6;
  width: 100%;
  border: none;
  outline: none;
  resize: none;
  background: transparent;
  font-family: inherit;
  color: inherit;
}
```
→ skipped: JS auto-resize listeners/cloned canvas calculations, add when: legacy browser support (< Safari 17.4) is strictly mandated.

---

### 2. Tabular Timeline & Baseline Alignment

```css
.log-stream {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.log-entry {
  display: grid;
  grid-template-columns: 4ch 1fr;
  align-items: first baseline;
  column-gap: 1.25rem;
}

.log-entry time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  letter-spacing: -0.01em;
  color: color-mix(in srgb, currentColor 40%, transparent);
  user-select: none;
}
```
→ skipped: Complex SVG timeline lines and absolute-positioned anchor nodes, add when: non-linear tree branching or edit-histories are introduced.

---

### 3. Keyboard-First Log Append (Cmd/Ctrl + Enter)

```js
// ponytail: ceiling is direct DOM injection; upgrade path is indexedDB + sync engine
const input = document.querySelector('.log-input');
const stream = document.querySelector('.log-stream');

input?.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && (e.metaKey || e.ctrlKey) && input.value.trim()) {
    e.preventDefault();
    const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
    const p = document.createElement('p');
    p.textContent = input.value.trim();
    
    const entry = document.createElement('div');
    entry.className = 'log-entry';
    entry.innerHTML = `<time>${time}</time>`;
    entry.appendChild(p);

    stream.prepend(entry);
    input.value = '';
  }
});
```
→ skipped: State store abstractions and form wrapper boilerplate, add when: offline persistence or multi-field metadata tags are introduced.


### Cycle #15 Directive (2026-11-02 22:31)
```css
/* 1. Auto-expanding log entry: Native CSS replaces JS resize listeners */
.log-input {
  field-sizing: content; /* ponytail: fallback to rows="1" on older browsers */
  min-height: 1.5lh;
  max-height: 12lh;
  line-height: 1.5;
  border: none;
  border-bottom: 1px solid var(--border, #e5e5ea);
  background: transparent;
  resize: none;
  font: inherit;
}

/* 2. Streamlined timeline spine: 2-column baseline alignment without DOM wrappers */
.log-stream {
  display: grid;
  grid-template-columns: auto 1fr;
  column-gap: 1rem;
  row-gap: 1.25lh;
  align-items: baseline;
  padding-inline-start: 0.75rem;
  border-inline-start: 1px solid var(--spine, #e5e5ea);
}
.log-stream time {
  font-size: 0.75rem;
  font-variant-numeric: tabular-nums;
  color: var(--muted, #8e8e93);
}
```

```html
<!-- 3. Minimal capture form: inline submit on Enter -->
<form class="log-form" onkeydown="if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();this.requestSubmit();}">
  <textarea name="entry" class="log-input" placeholder="Record awareness..." required></textarea>
</form>
```

→ skipped: JS auto-resize libraries, timeline SVG nodes, multi-div flex layouts.  
→ add when: explicit multi-day visual tagging or legacy browser support is demanded.


### Cycle #16 Directive (2026-11-02 22:37)
```css
/* 1. Micro-aligned log stream with zero layout drift */
.log-stream {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  max-width: 65ch;
  margin: 0 auto;
}

.log-entry {
  display: grid;
  grid-template-columns: 3.5rem 1fr;
  align-items: first baseline;
  gap: 1rem;
}

.log-entry time {
  font-variant-numeric: tabular-nums;
  font-size: 0.75rem;
  letter-spacing: -0.01em;
  color: var(--zen-muted, #8e8e93);
}
```
skipped: Timeline connector line graphics and custom icon SVGs.
add when: Non-linear journal branches or multi-day grouped hierarchies are required.

```css
/* 2. Zero-JS expanding conscious log textarea */
.log-input {
  /* ponytail: field-sizing requires Chrome 123+; falls back to static min-height */
  field-sizing: content;
  min-height: 2lh;
  max-height: 12lh;
  width: 100%;
  font-family: inherit;
  font-size: 1rem;
  line-height: 1.6;
  border: 0;
  outline: none;
  background: transparent;
  resize: none;
}
```
skipped: Dynamic JS height-calculation scripts and duplicate mirror elements.
add when: Strict legacy browser support requires synchronous manual resize syncing.

```html
<!-- 3. Minimal instant-capture hotkey pipeline -->
<form method="POST" action="/api/logs" onkeydown="if((event.metaKey||event.ctrlKey)&&event.key==='Enter'){this.requestSubmit();}">
  <textarea name="entry" class="log-input" placeholder="Observe without judging..." required autofocus></textarea>
</form>
```
skipped: External form state libraries and synthetic hotkey provider trees.
add when: Unsaved draft restoration via IndexedDB or multi-step prompt flows are implemented.


### Cycle #17 Directive (2026-11-02 22:43)
```css
/* 1. Streamlined log input: native auto-grow, zero JS textarea autosize listeners */
.log-input {
  field-sizing: content;
  min-height: 2.5lh;
  max-height: 40vh;
  resize: none;
  line-height: 1.6;
  border: none;
  outline: none;
  width: 100%;
  font-family: inherit;
  /* ponytail: fallback to ResizeObserver auto-height if iOS < 18 support is strictly required */
}

/* 2. Vertical micro-alignment: lock timestamps to first-line copy baseline */
.log-entry {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  align-items: first baseline;
  column-gap: 1.25rem;
  padding-block: 0.75rem;
}
.log-entry time {
  font-size: 0.75rem;
  font-variant-numeric: tabular-nums;
  color: var(--color-subtle, oklch(0.55 0.01 60));
}

/* 3. Zen vertical cadence: optical page-centering with margin collapse prevention */
.journal-canvas {
  min-height: 100dvh;
  display: grid;
  grid-template-rows: auto 1fr auto;
  max-width: 60ch;
  margin-inline: auto;
  padding-inline: 1.5rem;
  margin-trim: block;
}
```

* Skipped: JavaScript-based input autosizing and scroll trackers; add only if iOS 17 baseline compatibility is formally reported broken.
* Skipped: Complex CSS grid framework and spacing classes; add utility tokens only when log views exceed 3 distinct entry variants.
* Skipped: Empty-state illustration components; add inline text cue only if new-session telemetry shows entry abandonment.


### Cycle #18 Directive (2026-11-02 22:48)
### 1. Zero-JS Auto-Growing Entry Input

```css
/* ponytail: Native field-sizing handles auto-grow. Ceiling: Safari 17.4+ */
.log-input {
  field-sizing: content;
  min-height: 2lh;
  max-height: 40vh;
  line-height: 1.6;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
  border: none;
  outline: none;
  resize: none;
  background: transparent;
  width: 100%;
}
```
→ skipped: JS `scrollHeight` event listeners and hidden clone divs.  
→ add when: Legacy WebKit (< Safari 17.4) support is strictly required.

---

### 2. Streamlined Log Stream with Baseline Alignment

```html
<ol class="log-stream">
  <li>
    <time datetime="2025-05-14T08:00">08:00</time>
    <p>Observed cognitive drift during review; reset via breath.</p>
  </li>
</ol>
```

```css
.log-stream {
  list-style: none;
  padding-left: 1rem;
  border-left: 1px solid var(--border-subtle, #ece9e2);
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.log-stream li {
  display: grid;
  grid-template-columns: 3.5rem 1fr;
  align-items: first baseline;
  gap: 0.75rem;
}

.log-stream time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: var(--text-muted, #88847c);
}
```
→ skipped: Timeline dot markers and SVG connectors.  
→ add when: Multiple log categories or interactive status nodes are required.

---

### 3. Zen Warmth Tokens (Zero-Config Light/Dark)

```css
:root {
  --bg-zen: #fcfbf9;
  --text-main: #232220;
  --text-muted: #85827b;
  --border-subtle: #eeece6;
  color-scheme: light dark;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg-zen: #141312;
    --text-main: #ebe9e4;
    --text-muted: #7e7a73;
    --border-subtle: #262422;
  }
}

body {
  background: var(--bg-zen);
  color: var(--text-main);
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
}
```
→ skipped: Theme-switching state stores and LocalStorage keys.  
→ add when: Manual in-app toggle overrides system preference.


### Cycle #19 Directive (2026-11-02 22:54)
### 1. Auto-Growing Log Input (Native CSS, Zero JS)
Replaces manual JS height recalculations and textarea bloat.

```css
/* sadar-input.css */
.metacog-input {
  width: 100%;
  field-sizing: content;
  min-height: 1.6lh;
  max-height: 10lh;
  line-height: 1.6;
  padding-block: 0.25lh;
  border: none;
  outline: none;
  background: transparent;
  resize: none;
  font-family: inherit;
  /* ponytail: relies on Chromium 123+/Safari 17.4+; add JS resize fallback only if supporting legacy Safari */
}
```
`→ skipped: JS textarea auto-resize listener; add fallback when older browser metrics require it.`

---

### 2. Optical Vertical Alignment for Log Stream
Replaces loose flex containers with baseline grid rhythm and tabular time stamps.

```css
/* sadar-feed.css */
.log-stream {
  display: grid;
  row-gap: 0.75lh;
  padding: 0;
  list-style: none;
}

.log-entry {
  display: grid;
  grid-template-columns: 4.5ch 1fr;
  column-gap: 1.25rem;
  align-items: baseline;
}

.log-entry time {
  font-size: 0.75rem;
  font-variant-numeric: tabular-nums;
  color: var(--zen-muted, #8e8d8a);
  letter-spacing: -0.01em;
}

.log-entry p {
  margin: 0;
  line-height: 1.5;
  color: var(--zen-ink, #242423);
}
```
`→ skipped: custom date formatter libraries; add when relative date rollups ("2h ago") are requested.`

---

### 3. Native Tri-State Awareness Selector
Compact conscious state logger using native radio group and CSS `:has()` for zero-dependency toggle.

```html
<!-- sadar-state.html -->
<fieldset class="zen-toggle">
  <label><input type="radio" name="focus" value="present" checked><span>Present</span></label>
  <label><input type="radio" name="focus" value="wandering"><span>Wandering</span></label>
  <label><input type="radio" name="focus" value="anchor"><span>Anchor</span></label>
</fieldset>
```

```css
/* sadar-state.css */
.zen-toggle {
  border: none;
  padding: 0;
  display: inline-flex;
  gap: 0.25rem;
  background: var(--zen-bg-subtle, rgba(0, 0, 0, 0.04));
  padding: 2px;
  border-radius: 999px;
}
.zen-toggle input { position: absolute; opacity: 0; pointer-events: none; }
.zen-toggle label {
  padding: 0.2rem 0.65rem;
  font-size: 0.75rem;
  border-radius: 999px;
  cursor: pointer;
  color: var(--zen-muted, #737373);
  transition: background 120ms ease, color 120ms ease;
}
.zen-toggle label:has(:checked) {
  background: var(--zen-surface, #fff);
  color: var(--zen-ink, #171717);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
}
```
`→ skipped: segmented-control JavaScript components; add ARIA roving-tabindex only if multi-dimensional navigation is added.`


### Cycle #21 Directive (2026-11-02 23:06)
### 1. Unified Vertical Spine & Tabular Alignment

Eliminates flex misalignment between entry timestamps, rail markers, and text across variable font sizes.

```css
/* Layout: sadar-stream.css */
.log-stream {
  display: grid;
  grid-template-columns: minmax(3.5rem, auto) 1px 1fr;
  column-gap: 1.25rem;
  row-gap: 1.75rem;
  align-items: baseline;
}

.log-time {
  font-family: var(--font-mono, ui-monospace, monospace);
  font-variant-numeric: tabular-nums;
  font-size: 0.75rem;
  color: var(--zen-muted, #737373);
  text-align: right;
}

.log-rail {
  align-self: stretch;
  background-color: var(--zen-line, #e5e5e5);
  position: relative;
}

.log-rail::after {
  content: "";
  position: absolute;
  top: 0.35rem; /* Optical baseline lock with 0.875rem body */
  left: -2px;
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--zen-accent, #171717);
}

.log-body {
  font-size: 0.875rem;
  line-height: 1.5;
  color: var(--zen-ink, #1f1f1f);
}
```
* Skipped: Complex CSS subgrid polyfills and JS-based vertical centering calculations.
* Add when: Supporting legacy browsers without native CSS Grid column/row gap support.

---

### 2. Zero-JS Auto-Sizing Conscious Log Field

Uses native CSS `field-sizing` for anti-slop, distraction-free capture without autosize libraries or layout shifts.

```css
/* Input: conscious-entry.css */
.log-textarea {
  field-sizing: content;
  width: 100%;
  min-height: 1.5rem;
  max-height: 40vh;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  padding: 0;
  font-size: 0.875rem;
  line-height: 1.5;
  color: var(--zen-ink, #1f1f1f);
  box-shadow: none;
  /* ponytail: ceiling is modern chromium/safari 18; upgrade to hidden-div mirror only if legacy cross-browser auto-expand is mandated */
}

.log-textarea::placeholder {
  color: var(--zen-muted, #a3a3a3);
  font-style: normal;
}
```
* Skipped: Hidden DOM calculation clones, mutation observers, and textarea resizing packages.
* Add when: Hard business requirement to auto-expand on pre-Safari 18 or older Firefox versions.

---

### 3. Native Intent-Tagger (Prefix Extraction)

Captures state of mind directly via native input without extra dropdowns, modal pickers, or tagging UI.

```javascript
// log-parser.js
// ponytail: ceiling is leading bracket state; upgrade to regex tokenizer if compound tags are demanded
export function parseConsciousLog(raw) {
  const input = raw.trim();
  const match = input.match(/^\[([a-zA-Z\s]{1,16})\]\s*([\s\S]*)$/);
  
  return match
    ? { state: match[1].trim().toLowerCase(), note: match[2].trim() }
    : { state: "aware", note: input };
}

// Self-check
console.assert(parseConsciousLog("[calm] Breathing deeply").state === "calm");
console.assert(parseConsciousLog("Just sitting").state === "aware");
```
* Skipped: Natural language parsing engines, client-side NLP libraries, and custom tag picker widgets.
* Add when: Users require arbitrary key-value metadata schemas beyond baseline conscious states.


### Cycle #22 Directive (2026-11-02 23:12)
```css
/* 1. Conscious Log: Native zero-JS auto-expanding input */
.journal-input {
  field-sizing: content;
  min-height: 3.5rem;
  max-height: 40vh;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  line-height: 1.65;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", serif;
  color: #23201c;
}

/* 2. Vertical Alignment: Optical baseline snap for timeline stream */
.log-stream {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.log-entry {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  align-items: baseline;
  column-gap: 1.5rem;
}

.log-time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  color: #8a8278;
}

.log-text {
  line-height: 1.65;
  color: #23201c;
}

/* 3. Zen Focus Indicator: Subtle warm spine instead of heavy box-shadows */
.journal-container {
  background-color: #fcfbf8;
  border-left: 1.5px solid #e7e2d9;
  padding-left: 1.25rem;
  /* ponytail: manual transition; upgrade to view transitions if multi-pane */
  transition: border-color 180ms ease-out;
}

.journal-container:focus-within {
  border-left-color: #796e62;
}
```

skipped: JS `autosize` listeners; add when Firefox without `field-sizing` support drops below target threshold.
skipped: Complex multi-column grid layout; add when side-by-side reflection tagging is explicitly introduced.
skipped: Custom modal/sheet wrapper; keep log inline on the single zen surface until viewing density demands drawer splits.


### Cycle #23 Directive (2026-11-02 23:17)
### 1. Vertical Alignment & Baseline Locking (CSS)
Align entry timestamps, states, and reflection text strictly to the baseline without flexbox jitter or bespoke height calculations.

```css
.log-row {
  display: grid;
  grid-template-columns: 4.5ch 1fr;
  column-gap: 1.25rem;
  align-items: baseline;
  padding-block: 0.5lh; /* ponytail: upgrade to explicit rem if targeting legacy engines */
}

.log-row time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  opacity: 0.4;
}

.log-row p {
  margin: 0;
  line-height: 1.6;
}
```
→ skipped: complex flex wrappers, responsive breakpoints.  
→ add when: log rows introduce nested multi-column metadata tags.

---

### 2. Streamlined Log Input (Native Zero-JS Auto-grow)
Eliminate textarea-resizing JS scripts. Native auto-expansion anchored to line heights for flow-state writing.

```css
textarea.conscious-input {
  field-sizing: content; /* ponytail: upgrade to JS mirror-div if Safari < 17.4 support required */
  min-height: 1.6lh;
  max-height: 40vh;
  resize: none;
  border: none;
  outline: none;
  background: transparent;
  line-height: 1.6;
  font-family: inherit;
  padding: 0;
  transition: border-color 0.15s ease;
}

textarea.conscious-input:focus-visible {
  border-inline-start: 1.5px solid currentColor;
  padding-inline-start: 0.75rem;
}
```
→ skipped: auto-resize input event listeners, height caching logic.  
→ add when: client targets legacy browsers without modern `field-sizing`.

---

### 3. Minimalist Conscious Living Append (Store)
Store observations as timestamped tuples. No ORM, no client-side schema normalization.

```javascript
export const addLog = (body, kind = 'awareness') => {
  const text = body?.trim();
  if (!text) return null;
  const entry = { id: Date.now(), kind, text };
  localStorage.setItem('sadar_logs', JSON.stringify([entry, ...JSON.parse(localStorage.getItem('sadar_logs') || '[]')]));
  return entry;
};

// ponycheck: confirm entry persistence
console.assert(addLog('Recognized thought loop')?.text === 'Recognized thought loop', 'Append failed');
```
→ skipped: IndexedDB wrapper, reactive state stores, multi-device syncing.  
→ add when: log volume exceeds ~5MB or offline multi-tab conflict resolution is required.


### Cycle #24 Directive (2026-11-02 23:23)
### 1. Zero-JS Auto-Expanding Log Input

```css
textarea.journal-input {
  field-sizing: content;
  min-height: 3lh;
  max-height: 40vh;
  resize: none;
  line-height: 1.6;
  border: none;
  outline: none;
  background: transparent;
  /* ponytail: relies on native field-sizing; fallback remains standard scrollable box */
}
```
→ skipped: JS height recalculation listeners and hidden clone measuring DOMs.  
→ add when: Safari < 17.4 fallback is explicitly demanded by analytics.

---

### 2. First-Baseline Optical Alignment for Timeline Logs

```css
.log-stream-item {
  display: grid;
  grid-template-columns: 4.5rem 1fr;
  align-items: first baseline;
  column-gap: 1.25rem;
  padding-block: 0.625rem;
}

.log-stream-item time {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  letter-spacing: -0.01em;
}
```
→ skipped: Flexbox offset-nudging (`translateY`), tag wrappers, and manual pixel spacing.  
→ add when: Column drops to vertical stack on screen widths `< 320px`.

---

### 3. Native Zen Micro-Reflection Sheet

```html
<dialog id="reflection-sheet" class="zen-sheet">
  <form method="dialog">
    <textarea class="journal-input" placeholder="State without judgment..." autofocus></textarea>
    <footer class="sheet-actions">
      <button type="submit">Record</button>
    </footer>
  </form>
</dialog>
```

```css
.zen-sheet {
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 1rem;
  padding: 1.5rem;
  background: var(--surface-zen, #fafaf9);
}

.zen-sheet::backdrop {
  backdrop-filter: blur(12px);
  background: rgba(28, 25, 23, 0.2);
}
```
→ skipped: Custom focus-trap packages, portal layers, and modal state libraries.  
→ add when: Route-driven deep linking to opened logs is required.
