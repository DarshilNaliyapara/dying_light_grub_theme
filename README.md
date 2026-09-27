# Dying Light GRUB v21

## What changed vs v20 (real-hardware bug fix)

v20 tested on real hardware showed a visible step/ghosting at the
selected-item bar's edges. Root cause, confirmed against GRUB's own
theme spec: corner slices are drawn at native size, unscaled, and edge
slices scale only along their own axis. v20's corners were a flat 2x2
while the edges next to them (`select_w`=10px, `select_e`=56px,
`select_n`/`select_s`=6px) were bigger — so each corner didn't match the
edge it sits against, and GRUB drew a visible seam at every join.

v21 fix: corner assets now exactly match their adjoining edge thickness
(`select_nw`/`select_sw` = 10x6, `select_ne`/`select_se` = 56x6). Same
fix applied to `progress_frame_*` / `progress_hl_*` (corner was 3px vs a
6px cap — now both 6px). Also softened the top-sheen/bottom-shadow bevel
slightly (was ±30/38%, now ±18/22%) now that it renders as intended.
No `theme.txt` changes — total slice heights still sum to the same
`item_height`/`progress_bar height` as v20.

## Confirmed working from your photo

- Anton font loaded correctly (mixed-case "Advanced options for Arch
  Linux" is real Anton, not a Unifont fallback) — the pf2 pipeline works.
- Horizontal gradient measured pixel-by-pixel off your photo: smooth,
  monotonic, no banding — renders exactly as designed.
- Arrow renders and positions correctly.

## Known GRUB limitation (not fixable in theme.txt)

The selected-item highlight always spans the full configured
`boot_menu` width — same width for every entry, regardless of that
entry's text length. It does not hug text the way the game reference
does; GRUB's boot menu has no per-item dynamic width. This is why
"Arch Linux" gets a highlight that runs on well past the word. Current
`width = 55%` is sized so your longest visible entry ("Linux Firmware
Updater (EFI BootNext)") still fits without clipping — shrinking it
further to hug short entries would clip that one.

## Everything else

See previous README section below — font/progress-bar history from
v19→v20 unchanged.

---

# Dying Light GRUB v20

Matches the Dying Light 2 main-menu reference: Anton custom font, amber
gradient selected-item bar with embedded arrow, and a wired-up progress bar.

## What changed vs v19

- **Custom font (Anton, bold condensed).** v18 tried a custom PF2 and it
  broke with "PF2/CHIX" errors + bad spacing, so v19 fell back to GRUB's
  native Unifont everywhere. v20 fixes this properly: `Anton-Regular.ttf`
  ships in this folder, `install.sh` runs `grub-mkfont` at install time to
  bake it into `anton_16.pf2` / `anton_32.pf2` at the exact sizes
  `theme.txt` references (`"Anton Regular 16"`, `"Anton Regular 32"`).
  Pre-baked `.pf2` files are included too, as a fallback if `grub-mkfont`
  isn't available on install. `terminal-font` deliberately stays Unifont —
  Anton has no real lowercase and isn't meant for console text.
- **Selected-item bar rebuilt.** Bigger (`item_height` 42→60,
  `boot_menu height` 30%→36%), recolored to an amber gradient (deep on the
  left, brighter toward the arrow) with a subtle top-sheen/bottom-shadow
  bevel, matching pixel-sampled colors off the reference screenshots. Same
  embedded-arrow idea as v19, resized to fit.
- **Progress bar actually wired up.** v19 shipped `progress_frame_*.png`
  and `progress_hl_*.png` but never referenced them in `theme.txt`, so the
  bar rendered with no graphic at all. `bar_style` / `highlight_style` are
  now set, both recolored to the same amber family as the menu, and the
  countdown text moved to cream (`#f5ece0`) so it stays legible over both
  the dark track and the lit fill. Also fixed a text typo: "COMMING" →
  "COMING".

## Known leftovers (untouched, unreferenced)

`progress_bg.png`, `progress_fg.png`, `progress_tick.png`, and all
`unselected_item_*.png` files are pre-existing v19 assets not used by
`theme.txt`. Harmless to keep; delete them if you want a cleaner folder.

## Possible follow-ups

- If any of your real GRUB entry names are long (e.g. "Advanced options for
  Arch Linux"), they may run close to or past the 55% menu width at the
  bigger font. GRUB clips overflow rather than erroring, but widening
  `boot_menu.width` is an easy fix if you see it.
- Font/bar sizing was matched by pixel-sampling the two reference
  screenshots and compositing over your actual `background.png` — not from
  a live GRUB boot. Check on real hardware; nudge `item_padding` or
  `item_height` a little if spacing looks off.

## Install

```bash
unzip dying-light-grub-v20.zip
cd dying-light-grub-v20
sudo ./install.sh
```

Anton font: SIL Open Font License 1.1 (see `ANTON-OFL.txt`), from the
Anton Project Authors, via the google/fonts mirror.
