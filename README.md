# Omarchy customizations

Customizations for [Omarchy](https://omarchy.org) 4, made for UX/UI design work where a coding agent does the development. They add fixed workspaces, a Projects menu, design web apps, a dark theme, the pre-Tahoe macOS cursor and a dock. They were made on a 2018 MacBook Pro (T2).

## Install

```bash
git clone https://github.com/iretonsean/omarchy-customizations.git ~/Projects/omarchy-customizations
~/Projects/omarchy-customizations/install.sh
```

The script installs the packages, copies the files into your home folder and applies the theme. Before it replaces a file, it keeps a numbered backup next to it (for example `bindings.lua.~1~`). You can run it again at any time.

After the install, open **Super+Space → Learn → My Workspace** for the full guide.

## Coding agent

This repo does not install or choose a coding agent. The Projects menu starts the agent that you set in Omarchy:

```bash
omarchy default agent        # show the choices
omarchy default agent codex  # for example
```

## Add your projects

Projects are personal, so they are not in this repo. You keep them in one file:

```bash
cp ~/Projects/omarchy-customizations/projects.example.json ~/.config/omarchy/projects.json
# edit the file, then:
projects-apply
```

For each project, `projects-apply` builds:

- a submenu in the Projects menu (Super+D) with the project's sites, agent sessions, folder and terminal
- a web app launcher and icon for each site
- rules that open the project's sites on the project's workspace
- dock pins for the sites
- a row in Learn → My Workspace → Workspaces, and a line in the guide

Run `projects-apply` again after each change to `projects.json`.

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Short id, used in menu ids |
| `name` | yes | Name in the menu |
| `workspace` | yes | Workspace number for the project (2 or 3 in this layout) |
| `folder` | yes | Project folder. `~` is allowed. |
| `short` | no | Shorter name for the Learn menu (the menu is narrow) |
| `glyph` | no | Nerd Font glyph, as a character or a hex code point such as `f0f4` |
| `sites` | no | List of sites: `label`, `url`, and optional `name`, `icon` (URL or file) and `dock` (`false` to leave it out of the dock) |
| `sessions` | no | List of agent sessions: `label` and `folder`. Default: one "Agent session" in the project folder. |

## Save later changes

When the setup changes on the machine, copy the changes back into the repo and commit them:

```bash
~/Projects/omarchy-customizations/sync.sh
git -C ~/Projects/omarchy-customizations commit -am "Describe the change"
git -C ~/Projects/omarchy-customizations push
```

`sync.sh` updates only files that are already in `files/`. It empties the sections that `projects-apply` generates, so your projects stay out of the repo. To track a new file, copy it into `files/` at the same path it has under your home folder.

## What is in it

### Workspaces (`files/.config/hypr/workspaces.lua`)

| Key | Workspace | Contents |
|---|---|---|
| Super+1 | Agents | T3 Code, Claude |
| Super+2 | Project | Agent sessions and sites of a project |
| Super+3 | Project | The same, for another project |
| Super+4 | Design | Figma, Paper, Claude Design (always fully opaque) |
| Super+5 | Web | Normal browsing |
| Super+6 | Messages | HEY, WhatsApp, Discord, Signal, Google Messages |

### Menus (`files/.config/omarchy/extensions/omarchy-menu.jsonc`)

- **Projects (Super+D):** T3 Code, Claude, your projects and the design apps. Project rows run `files/.local/bin/project-open`.
- **Learn → My Workspace:** instructions for this setup. Each row also does the action it describes. The full guide is `files/.local/share/workspace-guide/index.html`.

### Keys (`files/.config/hypr/bindings.lua`)

| Key | Action |
|---|---|
| Super+D | Projects menu |
| Super+Shift+A | Claude (was ChatGPT) |
| Super+Shift+T | T3 Code |
| Super+Shift+I | Figma |
| Super+Shift+Alt+I | Paper |
| Super+Shift+Ctrl+I | Claude Design |
| Super+Ctrl+Shift+4 | Screenshot of an area to the clipboard |
| Super+V | Paste. In a terminal it also pastes images into agents that read them on Ctrl+V, such as Claude Code. |

### Web apps (`files/.local/share/applications/`)

Claude, Claude Design, Figma and Paper, with their icons. They run in Chromium, which Omarchy includes, so there is nothing to install. You only sign in. The hidden `chrome-*.desktop` files let the dock match a running web app to its pinned icon.

### Theme: Graphite (`files/.config/omarchy/themes/graphite/`)

- Dark neutral grays with a blue accent
- 12px rounded corners on windows and menus, soft shadows, 1px borders, no blur
- SF Pro in menus and GTK apps, SF Mono in the terminal and the bar
- Two backgrounds: "glow" and "plain"

The theme's color tokens are in `colors.toml`. Templates in `files/.config/omarchy/themed/` turn them into `graphite.css` (for HTML pages and GTK apps) and the `[graphite]` section of the shell theme (for the Omarchy shell). The design brief is `docs/theme-direction.md`.

## Graphite components

Omarchy 4 draws the bar, the menus, the panels and the overlays in one Quickshell process. This repo has Graphite copies of those plugins (`files/.config/omarchy/plugins/graphite.*`). They use shared parts from `plugins/graphite-ui/`: group, label, value field, button, switch, slider, keycap, chip, search field and more. `install.sh` turns them on. Omarchy's own files are not changed.

"Before" images show Omarchy as installed: the Tokyo Night theme, the JetBrainsMono Nerd Font and Omarchy's own plugins. All screenshots show made-up data. In `docs/screenshots/demo/`, `demo-mode on` makes the Graphite panels show made-up network names, devices, addresses and a made-up Wi-Fi QR code, and `vanilla-mode on` does the same for Omarchy's own panels. `off` restores your setup.

### Menu and keybindings

The Omarchy menu has named groups (Go to, Configure, System). The Keybindings view (Super+K) shows one keycap per key, in 11 sections with jump-to chips. Tab and Shift+Tab move between sections. Series such as workspaces 1 to 10 show as one row. The search matches names and keys, for example "super shift f" or "workspace 3".

| Menu, before | Menu, after |
|---|---|
| ![Omarchy menu before](docs/screenshots/menu-before-vanilla.png) | ![Omarchy menu with Graphite groups](docs/screenshots/menu-after.png) |

Keybindings, before:

![Omarchy Keybindings menu](docs/screenshots/keybindings-view-before.png)

Keybindings, after:

![Keybindings view with sections, chips and keycaps](docs/screenshots/keybindings-groups.png)

Search for "workspace 3", before and after:

![Omarchy Keybindings search](docs/screenshots/keybindings-search-before.png)

![Graphite Keybindings search](docs/screenshots/keybindings-search.png)

### Bar panels

Wi-Fi, Bluetooth, Audio, Display and Claude Code. One click on another bar icon switches to its panel.

| Before | After |
|---|---|
| ![Wi-Fi panel before](docs/screenshots/panel-network-before.png) | ![Wi-Fi panel after](docs/screenshots/panel-network-after.png) |
| ![Bluetooth panel before](docs/screenshots/panel-bluetooth-before.png) | ![Bluetooth panel after](docs/screenshots/panel-bluetooth-after.png) |
| ![Audio panel before](docs/screenshots/panel-audio-before.png) | ![Audio panel after](docs/screenshots/panel-audio-after.png) |
| ![Display panel before](docs/screenshots/panel-monitor-before.png) | ![Display panel after](docs/screenshots/panel-monitor-after.png) |
| ![Claude Code panel before](docs/screenshots/panel-agents-before.png) | ![Claude Code panel after](docs/screenshots/panel-agents-after.png) |

### Speed tests and Wi-Fi sharing

| | Before | After |
|---|---|---|
| Internet speed | ![Internet speed test before](docs/screenshots/speedtest-before.png) | ![Internet speed test after](docs/screenshots/speedtest-after.png) |
| Disk speed | ![Disk speed test before](docs/screenshots/disk-speedtest-before.png) | ![Disk speed test after](docs/screenshots/disk-speedtest-after.png) |
| Wi-Fi QR code | ![Wi-Fi QR code before](docs/screenshots/wifiqr-before.png) | ![Wi-Fi QR code after](docs/screenshots/wifiqr-after.png) |

### Notifications

Notifications are Graphite panels: no border, the title in SF Pro, the time since arrival at the right edge ("now", "2m") and line icons in the accent color. App icons and images keep rounded corners. Critical notifications show "urgent". The behavior is Omarchy's: do not disturb, history and the keybindings work as before. `docs/screenshots/demo/demo-notifications` sends a set of made-up notifications.

### Files

Graphite styles for the Files app (Nautilus) in `files/.config/gtk-4.0/gtk.css`. A small library (`files/.local/src/gtk4-pointer/`) gives GTK 4 apps the hand cursor on clickable items.

| Before | After |
|---|---|
| ![Files before](docs/screenshots/files-before.png) | ![Files after](docs/screenshots/files-after.png) |
| ![Files list before](docs/screenshots/files-before-list.png) | ![Files list after](docs/screenshots/files-after-list.png) |

### Workspace guide

The guide page (`files/.local/share/workspace-guide/index.html`) is also the component sheet. Omarchy has no guide page, so there is no "before" image.

![Workspace guide](docs/screenshots/guide-after.png)

[The full guide page](docs/screenshots/guide-after-full.png)

### Cursor

The pre-Tahoe macOS cursor theme (`apple_cursor` package), set in `files/.config/hypr/looknfeel.lua` and `files/.icons/default/index.theme`.

### Dock

A Graphite plugin in the Omarchy shell (`files/.config/omarchy/plugins/graphite.dock/`) at the bottom of the screen. It hides until the pointer reaches the bottom edge. Right-click an icon to pin or unpin it, add or remove a gap, or empty the trash. Omarchy has no dock, so there is no "before" image. The Graphite dock replaces `nwg-dock-hyprland`, which drew blurry and missing icons. The base pins are still in `files/.config/nwg-dock-hyprland/pinned`, and `projects-apply` adds your project sites. To go back to `nwg-dock-hyprland`, run `omarchy plugin disable graphite.dock`, then `dock-start`.

![Graphite dock](docs/screenshots/dock-after.png)

### Display

`files/.config/hypr/monitors.lua` sets scale 2 for the MacBook's Retina screen. Change it for other screens.

## Known issue: Omarchy's Keybindings menu in SF Pro

The Graphite menu draws keybindings as keycaps (see above), so this issue shows only with Omarchy's own menu. Omarchy's Keybindings menu (Super+K) lines up its columns with spaces, which works only in a monospace font. With SF Pro as the menu font, the arrows do not line up:

![Keybindings menu in SF Pro, columns not aligned](docs/screenshots/keybindings-before.png)

A fix for Omarchy is ready but not yet submitted. It lets the menu draw real columns, measured in the menu's own font:

| SF Pro | Monospace | Filtered |
|---|---|---|
| ![After, SF Pro](docs/screenshots/keybindings-after-sf-pro.png) | ![After, monospace](docs/screenshots/keybindings-after-monospace.png) | ![After, filtered](docs/screenshots/keybindings-after-filtered.png) |

Until Omarchy includes the fix, Omarchy's own menu has the "before" behavior.

## Packages

| Package | Source | Used for |
|---|---|---|
| `nwg-dock-hyprland` | Arch | Old dock, kept as a fallback |
| `breeze-icons` | Arch | Icon for the Projects launcher |
| `otf-apple-sf-pro` | AUR | SF Pro font |
| `nerd-fonts-sf-mono` | AUR | SF Mono with Nerd Font icons |
| `apple_cursor` | AUR | Pre-Tahoe macOS cursor theme |
| `t3code-bin` | Omarchy | T3 Code, a window for coding agent sessions, installed with `omarchy install ai t3 code` |

The SF fonts are licensed for use on Apple hardware only. Alternatives for other computers are planned.

## Not in this repo

- **Your projects:** they go in `~/.config/omarchy/projects.json` (see above).
- **A coding agent:** install and choose your own.
- **Logins:** T3 Code, your agent and the web apps each need you to sign in.
- **Omarchy's own files:** only files that differ from Omarchy's defaults are here.

## License

MIT, see [LICENSE](LICENSE). The SF fonts, the cursor theme and the app icons are not part of this license; they keep their own terms.

Project page: [seanireton.com/graphite](https://seanireton.com/graphite)
