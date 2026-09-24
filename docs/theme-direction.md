# Graphite: next design pass

A design brief for the next work on the Graphite theme. The colors and fonts stay as they are. This pass gives Graphite a component system, so that every Omarchy surface uses the same parts in the same way.

Reference: a UI concept by [@iamdothash](https://x.com/iamdothash). Graphite takes its rules (one set of parts, the accent only for state, generous space) and not its forms (centered cards, pill controls, monospace for all text, lavender).

Visual reference: [`docs/design/direction-d.html`](design/direction-d.html). Open it in a browser at 1440 × 900. It is a static mockup of direction D: the menu, keybindings, appearance settings, a notification, the calendar and the volume OSD. Its values match the tokens below. If the mockup and this brief do not agree, the brief is correct.

Direction D came from four explorations: A Inspector, B Grouped, C Anchored and D Combined. D is the one to build.

## Summary

Direction D combines three explorations:

| From | Graphite uses |
|---|---|
| Grouped | Rows in groups. The group name is the first line inside the group. |
| Inspector | Values in SF Mono, often in small fields with units ("12 px"). Compact rows for data. |
| Anchored | No borders. Depth comes from tone and shadow. The focused row lifts. Keycaps are outlined. |

Panels float. They do not grow out of the bar or a screen edge.

The groups must not look like macOS. So there are no inset dividers, no icon tiles, no `›` chevrons, no round toggles and no large display titles.

## Rules

1. **Lift = where you are.** Keyboard focus and hover lift the row: a lighter fill, a top highlight and a small shadow.
2. **Blue fill = what is chosen.** Toggle on, today, the selected accent, a slider fill. Blue never marks focus.
3. **Labels in SF Pro, values in SF Mono.** Numbers, keys, times, file names and counts are always mono.
4. **No borders.** Tone and shadow separate surfaces. The only lines are keycap outlines.
5. **Groups carry their own name.** The group name and a mono count sit inside the group, on its first line.

## Tokens

### Color

| Token | Value | Use |
|---|---|---|
| `surface-0` | `#0e0e10` | Screen behind panels, lock screen |
| `surface-1` | `#18181a` | Panel, value field |
| `surface-2` | `#222224` | Group |
| `surface-3` | `#2c2c2e` | Toggle off, slider track |
| `lift` | `#303033` | Focused row |
| `text-1` | `#f5f5f7` | Titles, focused row |
| `text-2` | `#e5e5e7` | Normal text |
| `text-3` | `#98989d` | Values, meta, icons, counts |
| `text-4` | `#636366` | Disabled items and days outside the month only (3:1 on `surface-1`) |
| `accent` | `#0a84ff` | Toggle on, slider and progress fill, focused icon |
| `accent-soft` | `#6cb4ff` | Fills with dark text (today), links |
| `on-accent` | `#0e0e10` | Text on `accent-soft` |
| `label-tint` | `#7d8aa3` | Group names, weekday letters |
| `ok` | `#7fd48f` | "connected", "4 files changed" |
| `warn` | `#ffcc66` | "3 ready" |
| `error` | `#ff8078` | "failed" |
| `keycap-edge` | `rgba(255,255,255,0.14)` | Keycap outline |
| `highlight` | `rgba(255,255,255,0.06)` | 1px top highlight on panels and the focused row |

Contrast on `surface-1`: `text-3` 6.2:1, `label-tint` 5.1:1, `ok` 9.9:1, `error` 7.3:1. `on-accent` on `accent-soft`: 8.8:1.

### Shape

| Token | Value |
|---|---|
| Panel radius | 16px |
| Group radius | 8px |
| Row radius | 6px |
| Field and keycap radius | 5px |
| Toggle | Track 36 × 18px, 5px radius. Knob 16 × 14px, 3px radius, 2px from the track edge (inner radius = outer radius − inset). |
| Window rounding | 12px (no change) |
| Panel shadow | `inset 0 1px 0 highlight, 0 20px 48px rgba(0,0,0,0.55)` |
| Lift shadow | `inset 0 1px 0 highlight, 0 2px 8px rgba(0,0,0,0.4)` |

### Space

| Token | Value |
|---|---|
| Panel padding | 16px |
| Group padding | 4px |
| Gap between rows | 2px |
| Gap between groups | 10px |
| Navigation row | 36px high, 8px side padding, 10px from icon to label |
| Data row | 30px high |
| Group name row | 26px high |

### Type

| Role | Font | Size | Weight | Color |
|---|---|---|---|---|
| Panel title | SF Pro Text | 15px | 600 | `text-1` |
| Panel meta (right of title) | SF Mono | 11px | 400 | `text-3` |
| Group name | SF Pro Text | 11px | 600 | `label-tint` |
| Group count | SF Mono | 11px | 400 | `text-3` |
| Navigation row | SF Pro Text | 14px | 400 | `text-2` |
| Data row | SF Pro Text | 13px | 400 | `text-2` |
| Value | SF Mono | 12px | 400 | `text-3` |
| Keycap | SF Mono | 11px | 400 | `text-2` |

## Components

1. **Panel:** `surface-1`, 16px radius, panel shadow, 16px padding. Title row: title left, mono meta right (for example "super space" or "48 bindings").
2. **Group:** `surface-2`, 8px radius, 4px padding. First line: group name left, mono count or value right. No dividers.
3. **Row:** 6px radius. Line icon (15px, `text-3`), label, value or keys at the right edge. Focused: `lift` fill, lift shadow, text `text-1`, icon `accent`.
4. **Value field:** `surface-1` inside a group, 22px high, 5px radius, SF Mono 12px, unit in `text-3` ("12 px", "4 in", "8 out").
5. **Keycap:** one per key, 20px high, 1px `keycap-edge` outline with a 2px bottom edge, 5px radius, 4px between keys. Symbols for ⇧ and ↵; words for super, alt, ctrl, esc.
6. **Toggle:** rounded rectangle as in Shape. Off: `surface-3` track with an inner shadow (`inset 0 1px 2px rgba(0,0,0,0.45)`), `#c7c7cc` knob on the left. On: `accent` track with a top highlight (`inset 0 1px 0 rgba(255,255,255,0.18)`), white knob on the right. Knob shadow in both states: `0 1px 2px rgba(0,0,0,0.4)`.
7. **Slider:** 4px track in `surface-3`, `accent` fill, value field on the right ("62 %").
8. **Status text:** SF Mono 12px in `ok`, `warn` or `error`.
9. **Notification:** a panel with 12px padding. Line icon in `accent-soft`, title 14px semibold, mono time right, body in `text-3`.
10. **Calendar:** weekday letters in `label-tint`, days in SF Mono, weekends in `text-3`, days outside the month in `text-4`, today as an `accent-soft` square (6px radius) with `on-accent` text.
11. **OSD:** a small panel (48px high, 14px radius) with an icon, a slider and a value field.

## Surfaces, in order of value

| # | Surface | What to change | Notes |
|---|---|---|---|
| 1 | Omarchy menu (`omarchy.menu`) | Panel, groups with names, rows with line icons, lift for focus, keycaps for shortcuts. Remove the 2px blue border. | Needs a clone of the plugin. The stock menu has no groups or keycaps, and its radius follows the window rounding. |
| 2 | Keybindings (Super+K) | Two columns of groups (Launch, Design, Windows, Workspaces, Other), keycaps | The same menu clone, in dmenu mode. The clone splits each line into keycaps, so the column fix in the README is not needed. Bindings outside the four groups go in "Other". |
| 3 | Notifications (`omarchy.notifications`) | Notification component, with the time at the right edge | Needs a clone. The stock card shows no time and uses a fixed "Liberation Sans" title. |
| 4 | Bar clock and calendar (`omarchy.clock`) | Mono clock, calendar component | The calendar is a QML panel. In a clone, today can be a filled `accent-soft` square. |
| 5 | OSD (`omarchy.osd`) | OSD component | Needs a clone. |
| 6 | Dock (nwg-dock) | Tokens, not fixed hex values | GTK CSS imports a file generated from the tokens. Also makes the dock follow the theme. |
| 7 | Lock screen (`omarchy.lock`) | Mono clock, password field as a value field | Needs a clone. |
| 8 | Workspace guide (HTML) | All components | Full control. Build it first as the component sheet. |

Wi-Fi and Bluetooth are terminal apps (impala and bluetui). They take only the terminal colors.

## Order for the session

1. Build the workspace guide as the component sheet. It is HTML, so every component can be made exactly and checked on screen.
2. Put the tokens in the theme folder.
3. Apply them to the menu, then keybindings, notifications, the clock and calendar, the OSD, the dock and the lock screen.
4. Take a screenshot of each surface before and after, into `docs/screenshots/`.
5. Update the README theme section.

## How Omarchy 4 does it

Checked on Omarchy 4.0.4. Omarchy is installed at `/usr/share/omarchy` and is not edited.

- **One shell.** Waybar, mako, swayosd and hyprlock are not used. One Quickshell process draws the bar, menu, notifications, OSD, calendar and lock screen. Each is a plugin in `/usr/share/omarchy/shell/plugins/`.
- **Theme files.** The shell reads five colors from `colors.toml` (foreground, background, accent, red, muted) and each surface's colors, border widths, spacing and font sizes from `shell.toml`. The panel radius follows Hyprland's `decoration.rounding`. Theme files cannot add groups, keycaps, shadows or new layouts.
- **Clones.** `omarchy plugin clone <id>` copies a plugin to `~/.config/omarchy/plugins/`. The copy replaces the built-in plugin, reloads on save and survives updates. It does not get Omarchy's later fixes to that plugin.
- **Tokens.** `colors.toml` accepts extra keys and passes them to templates as `{{ key }}`. The tokens live in `themes/graphite/colors.toml`. User templates in `~/.config/omarchy/themed/` turn them into `graphite.css` (for HTML and GTK) and a `[graphite]` section in `shell.toml` (for the clones). Other themes get fallback values.

## Directions to explore

These are open design questions. They come after the build in "Order for the session" and do not block it. Test each one on the machine, keep what works, and put the result in this brief.

1. **Visible keyboard focus.** The lift (`#303033` on `#222224`) is quiet. Check if you can find the focused row at a glance while you type in the menu. If not, add a second signal for keyboard focus only, for example a 1px `accent` inner edge. Keep the lift alone for hover.
2. **Window focus.** The rules say blue marks what is chosen, and the focused window is a kind of choice. Compare two versions: the current blue border (`rgba(0a84ffb3)`), and no colored border with Hyprland's `dim_inactive` at a low value. Pick the version where you find the focused window faster.
3. **Motion.** Give every panel the same entry: a fade and a scale from 0.98, 120–160ms, ease-out. The toggle knob slides in 120ms. The lift fades in 80ms. Set the Hyprland layer animations to match and check that the menu does not feel slow.
4. **The bar.** Waybar does not follow the D rules yet. Try workspace numbers in SF Mono, the current workspace shown with a lift and not a color, and status values as mono text in `text-3` that turns `warn` or `error` only when something needs attention.
5. **Background.** Dark panels on the graphite glow have low contrast between panel and wall. Try a background with more tone change (a lighter graphite texture or a soft grain), and check that panels still look separate without borders.
6. **Density.** The menu uses 36px rows and data uses 30px rows. Use the menu for a day at each size and check whether one row height for everything is enough.
7. **Icons.** Pick one line-icon set with a stroke that matches SF Pro at 15px (about 1.5–1.8px), and map the Omarchy menu's Nerd Font glyphs to it. Mixed icon styles make the menu look unfinished quickly.
8. **States.** Design what each surface shows when something is empty, running or failed. Examples: no notifications, an update in progress, no Wi-Fi, a failed download. Use the status colors and mono text; do not add new colors.
9. **Terminal and editor.** Make the terminal padding, cursor and selection color match the tokens, so that the terminal looks like part of the same system as the panels.
10. **A light variant (optional).** The tokens are named by role, not by color. Make a light set to test the system. If the rules still work in light, the component system is correct. If they do not, find which rule depends on a dark background.
