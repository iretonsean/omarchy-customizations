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

### Cursor

The pre-Tahoe macOS cursor theme (`apple_cursor` package), set in `files/.config/hypr/looknfeel.lua` and `files/.icons/default/index.theme`.

### Dock

`nwg-dock-hyprland` at the bottom of the screen. It hides until the pointer reaches the bottom edge. `files/.local/bin/dock-start` starts it, and `files/.config/hypr/autostart.lua` runs that at login. The base pins are in `files/.config/nwg-dock-hyprland/pinned`. `projects-apply` adds your project sites after Projects and writes the result to `~/.cache/nwg-dock-pinned`.

### Display

`files/.config/hypr/monitors.lua` sets scale 2 for the MacBook's Retina screen. Change it for other screens.

## Known issue: Keybindings menu in SF Pro

The Keybindings menu (Super+K) lines up its columns with spaces, which works only in a monospace font. With SF Pro as the menu font, the arrows do not line up:

![Keybindings menu in SF Pro, columns not aligned](docs/screenshots/keybindings-before.png)

A fix for Omarchy is ready but not yet submitted. It lets the menu draw real columns, measured in the menu's own font:

| SF Pro | Monospace | Filtered |
|---|---|---|
| ![After, SF Pro](docs/screenshots/keybindings-after-sf-pro.png) | ![After, monospace](docs/screenshots/keybindings-after-monospace.png) | ![After, filtered](docs/screenshots/keybindings-after-filtered.png) |

Until Omarchy includes the fix, this repo has the "before" behavior.

## Packages

| Package | Source | Used for |
|---|---|---|
| `nwg-dock-hyprland` | Arch | Dock |
| `breeze-icons` | Arch | Icon for the Projects launcher |
| `otf-apple-sf-pro` | AUR | SF Pro font |
| `nerd-fonts-sf-mono` | AUR | SF Mono with Nerd Font icons |
| `apple_cursor` | AUR | Pre-Tahoe macOS cursor theme |
| `t3code-bin` | Omarchy | T3 Code, a window for coding agent sessions, installed with `omarchy install ai t3 code` |

The SF fonts are licensed for use on Apple hardware only.

## Not in this repo

- **Your projects:** they go in `~/.config/omarchy/projects.json` (see above).
- **A coding agent:** install and choose your own.
- **Logins:** T3 Code, your agent and the web apps each need you to sign in.
- **Omarchy's own files:** only files that differ from Omarchy's defaults are here.
