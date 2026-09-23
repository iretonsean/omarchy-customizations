# Graphite: next design pass

A design brief for the next work on the Graphite theme. It uses a UI concept by [@iamdothash](https://x.com/iamdothash) as a reference. The goal is to take the concept's system, not its look.

## Summary

Graphite already has good colors. It does not have a component system. The concept is strong because every panel uses the same small set of parts: a card, a row, a pill, a keycap, a toggle, a thin bar and a section label. Each part has one shape, one spacing value and one way to show "selected".

The next pass must:

1. Define these parts once, as tokens, in the Graphite theme folder.
2. Apply them to each Omarchy surface that can be styled: menus, keybindings, notifications, the clock and calendar, OSD sliders, the lock screen, the dock and the workspace guide.
3. Keep what makes Graphite different: the blue accent, SF Pro for labels and SF Mono for values.

## What the concept does

The reference has six panels: Settings, Downloads, Calendar, Wi-Fi/Bluetooth, Notifications and Keybindings.

| Part | How the concept does it |
|---|---|
| Panel | Dark card, large radius (about 20px), 1px border that is almost invisible. The panel floats over a colorful background. |
| Row | Full-width rounded block (about 12px radius), large padding, a label on the left and a value on the right. |
| Selected state | A lighter fill on the row. No border, no color change on the text. |
| Accent | One soft lavender. It is used only for state: selected tab, toggle on, slider fill, progress fill, today in the calendar. |
| Text on accent | Dark text on the light accent fill (the "Wi-Fi" tab, "22" in the calendar). |
| Section label | Small caps, wide letter spacing, low contrast, tinted toward the accent ("LAUNCH", "DOWNLOADS"). |
| Secondary text | Gray and small: "780 MB of 1.2 GB · 12 MB/s", "now", "2m". A middle dot separates values. |
| Status | Short words in muted color: green "done", red "failed · retry", gray "secured". No icons. |
| Keycap | Each key is its own small rounded chip with a slightly lighter fill ("super", "space", "1-9"). |
| Controls | Pill toggles, a thin rounded slider with the value as a number next to it, a segmented control for tabs. |
| Clock | A separate pill with an accent border, time in bright text and the date in gray. |
| Type | One monospace family everywhere. |
| Empty space | Few items per panel and a lot of padding. Nothing is dense. |

## What to take and what to leave

| Take | Leave |
|---|---|
| The component set and the rules for state | The lavender and purple palette. It is Tokyo Night's color, and it is the concept's identity. |
| Accent used only for state, never for decoration | Monospace for all text. Graphite uses SF Pro for labels. |
| Selected state as a lighter fill | The purple wave wallpaper |
| Keycap chips for shortcuts | The 2px accent border on the Settings panel (Graphite's menu has this now; see below) |
| Status as short colored words | |
| Dark text on accent fills | |

## Graphite's own direction

- **Accent:** keep blue. Add a light blue for fills, so that dark text on it is readable. Saturated `#0a84ff` with white text has a contrast of about 3.6:1, which is too low for small text. Dark text on `#0a84ff` is about 5.3:1.
- **Type:** SF Pro Text for labels and titles. SF Mono for values, numbers, keycaps, times and file names. This mix is the main difference from the concept, and it makes values easy to scan.
- **Borders:** 1px, white at 8%. Remove the 2px blue border from the menu. The focus state is the lighter row fill, not the panel border.
- **Background:** keep the Graphite backgrounds. Panels must work over a plain dark image, not only over a colorful one.

## Tokens

Add these to `colors.toml` if Omarchy passes extra keys to its templates. If it does not, keep them in one CSS or QML file that the other files import. Check this on the machine.

### Color

| Token | Value | Use |
|---|---|---|
| `surface-0` | `#0e0e10` | Screen behind panels, lock screen |
| `surface-1` | `#18181a` | Panel background |
| `surface-2` | `#222224` | Row background, notification card |
| `surface-3` | `#2c2c2e` | Selected row, keycap, segmented control track |
| `border` | `rgba(255,255,255,0.08)` | Panel and card edges |
| `text-1` | `#f5f5f7` | Titles, selected value |
| `text-2` | `#e5e5e7` | Normal text |
| `text-3` | `#98989d` | Secondary text, values |
| `text-4` | `#636366` | Disabled items and dividers only. Contrast on `surface-1` is 3:1, too low for text you must read. |
| `accent` | `#0a84ff` | Slider and progress fill, toggle on |
| `accent-soft` | `#6cb4ff` | Fills with dark text: selected tab, today, primary button |
| `on-accent` | `#0e0e10` | Text on `accent` and `accent-soft` |
| `label-tint` | `#7d8aa3` | Section labels (gray with a small amount of blue) |
| `ok` | `#7fd48f` | "done", "connected" |
| `warn` | `#ffcc66` | "paused", "low" |
| `error` | `#ff8078` | "failed", "retry" |

Contrast on `surface-1`: `text-3` 6.2:1, `label-tint` 5.1:1, `ok` 9.9:1, `error` 7.3:1, `on-accent` on `accent-soft` 8.8:1.

The status colors are lighter and less saturated than the terminal colors. Small text in saturated green or red looks too bright on a dark panel.

### Shape and space

| Token | Value |
|---|---|
| `radius-panel` | 20px |
| `radius-row` | 12px |
| `radius-key` | 8px |
| `radius-pill` | 999px |
| `space` | 4px base; use 8, 12, 16, 24 |
| `panel-padding` | 24px |
| `row-height` | 48px (menus), 56px (settings-style rows) |
| `row-padding` | 0 16px |
| `row-gap` | 4px |
| `section-gap` | 24px |
| window `rounding` | 12px (no change) |
| window `gaps_out` | 8px (no change) |

### Type

| Role | Font | Size | Weight | Other |
|---|---|---|---|---|
| Panel title | SF Pro Display | 20px | 600 | |
| Row label | SF Pro Text | 14px | 400 | |
| Value | SF Mono | 13px | 400 | `text-3` |
| Section label | SF Pro Text | 11px | 600 | all caps, letter spacing 0.1em, `label-tint` |
| Keycap | SF Mono | 12px | 500 | lower case, `surface-3` fill |
| Meta (time, size) | SF Mono | 12px | 400 | `text-3` |

## Components

1. **Panel:** `surface-1`, `border`, `radius-panel`, shadow `0 8px 32px rgba(0,0,0,0.45)`, `panel-padding`.
2. **Row:** `radius-row`, no fill at rest, `surface-3` when selected. Label left, value right. The text color does not change on selection.
3. **Section label:** above a group of rows, `section-gap` above it and 8px below it.
4. **Keycap:** one chip per key, 6px between chips, `radius-key`. Use symbols for modifiers where they are clear: ⇧, ↵, ⌫. Keep "super", "alt" and "ctrl" as words.
5. **Toggle:** 36 × 20px pill. Off: `surface-3` track, `text-4` knob. On: `accent` track, white knob.
6. **Slider and progress:** 4px track in `surface-3`, `accent` fill, round ends. Show the value as a number in SF Mono to the right.
7. **Segmented control:** `surface-2` track, `accent-soft` fill for the selected segment with `on-accent` text.
8. **Status word:** SF Mono 12px in `ok`, `warn` or `error`. Separate two words with " · ".
9. **Notification card:** `surface-2`, `radius-row`, 32px icon with 8px radius, bold title, body in `text-2`, time in `text-3`.
10. **Clock pill:** `radius-pill`, 1px `accent` border at 60%, time in `text-1`, date in `text-3`.

## Surfaces, in order of value

| # | Surface | What to change | Notes |
|---|---|---|---|
| 1 | Omarchy menu and launcher (Quickshell) | Panel, rows, selected state, section labels, remove 2px blue border | Most-used surface. Find where the Quickshell menu reads its theme. |
| 2 | Keybindings (Super+K) | Keycap chips, two columns, grouped with section labels | Goes with the column fix in the README. Keycaps need one element per key, so this needs the menu to draw columns. |
| 3 | Notifications (mako) | Notification card, status colors, icon radius | Mako cannot right-align the time. Put it after the title or leave it out. |
| 4 | Waybar clock and calendar | Clock pill, today as `accent-soft` fill with `on-accent` text | The calendar tooltip supports Pango markup. A filled circle may not be possible there; a bold, colored date is. |
| 5 | OSD (swayosd) | Thin slider, value as a number | |
| 6 | Dock (nwg-dock) | Use tokens, not fixed hex values | Fixes the gap where the dock does not follow the theme. |
| 7 | Lock screen (hyprlock) | Clock pill style, password field as a row | |
| 8 | Workspace guide (HTML) | Panels, rows, keycaps, section labels | Full control in HTML. Use it as the reference page for the components. |

Wi-Fi and Bluetooth in Omarchy are terminal apps (impala and bluetui). They take only the terminal colors, so the segmented control and status words from the concept do not apply there without a new widget.

## Suggested order for the session

1. Build the workspace guide first, as a component sheet. It is HTML, so every component can be made exactly and checked on screen.
2. Move the tokens into the theme folder.
3. Apply them to the Quickshell menu, then keybindings, then mako, waybar, swayosd, the dock and hyprlock.
4. Take screenshots of each surface before and after, into `docs/screenshots/`.
5. Update the README theme section.

## Check on the machine

- Which files in a theme folder Omarchy 4 reads for the Quickshell menu, waybar, mako, swayosd and hyprlock.
- Whether `colors.toml` accepts extra keys and passes them to templates.
- Whether the Quickshell menu can draw one chip per key, or only a text line.
