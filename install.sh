#!/bin/bash

# Install these Omarchy customizations on this machine.
#
# - Installs the packages they need.
# - Copies everything under files/ into $HOME. Each file that is replaced
#   gets a numbered backup next to it (for example bindings.lua.~1~).
# - Builds the project parts from ~/.config/omarchy/projects.json, if you have one.
# - Applies the Graphite theme, fonts and cursor, and starts the dock.
#
# It does not install or choose a coding agent. The Projects menu starts the
# agent you set with `omarchy default agent`.
#
# Run it again at any time. It only copies and re-applies.

set -euo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if ! command -v omarchy >/dev/null; then
  echo "Omarchy is not installed. These files need Omarchy 4." >&2
  exit 1
fi

echo "==> Packages"
omarchy-pkg-add nwg-dock-hyprland breeze-icons
omarchy-pkg-aur-add otf-apple-sf-pro nerd-fonts-sf-mono apple_cursor
if ! command -v t3code >/dev/null; then
  omarchy install ai t3 code
fi

echo "==> Files"
cd "$REPO/files"
while IFS= read -r -d '' file; do
  target="$HOME/${file#./}"
  mkdir -p "$(dirname "$target")"
  cp --backup=numbered "$file" "$target"
done < <(find . -type f -print0)
chmod +x "$HOME/.local/bin/project-open" "$HOME/.local/bin/projects-apply" "$HOME/.local/bin/dock-start" "$HOME/.local/bin/dock-pins" "$HOME/.local/bin/gtk4-pointer-run" "$HOME/.local/bin/files-open" "$HOME/.local/bin/trackpad-momentum" "$HOME/.local/bin/terminal-paste"

echo "==> Pointer cursor in GTK 4 apps"
# Builds the library from files/.local/src/gtk4-pointer and starts Files
# through it (see ~/.config/gtk-4.0/pointer.conf). D-Bus service files cannot
# use $HOME, so this one is written here with the full path.
mkdir -p "$HOME/.local/lib" "$HOME/.local/share/dbus-1/services"
if gcc -shared -fPIC -O2 -o "$HOME/.local/lib/libgtk4-pointer.so" \
    "$HOME/.local/src/gtk4-pointer/gtk4-pointer.c" $(pkg-config --cflags gtk4); then
  printf '[D-BUS Service]\nName=org.gnome.Nautilus\nExec=%s /usr/bin/nautilus --gapplication-service\n' \
    "$HOME/.local/bin/gtk4-pointer-run" >"$HOME/.local/share/dbus-1/services/org.gnome.Nautilus.service"
  busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus ReloadConfig >/dev/null 2>&1 || true
else
  echo "Could not build gtk4-pointer (it needs gcc and gtk4). Skipping it." >&2
fi

echo "==> Trackpad"
"$REPO/system-setup.sh"

echo "==> Projects"
"$HOME/.local/bin/projects-apply"

echo "==> Theme, fonts and cursor"
omarchy theme set graphite
# The dock is a shell plugin (files/.config/omarchy/plugins/graphite.dock).
omarchy plugin enable graphite.dock >/dev/null
# Graphite versions of the menu, the bar panels and the notifications replace
# the built-in ones.
for panel in menu agents bluetooth network audio monitor speedtest disk-speedtest wifiqr notifications; do
  omarchy plugin enable "graphite.$panel" >/dev/null
done
omarchy font set "SFMono Nerd Font Mono"
gsettings set org.gnome.desktop.interface font-name 'SF Pro Text 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'SFMono Nerd Font Mono 11'
gsettings set org.gnome.desktop.interface cursor-theme 'macOS'

if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  echo "==> Reload"
  hyprctl reload >/dev/null
  hyprctl setcursor macOS 24 >/dev/null
  # Restart the shell from Hyprland so it gets the SF Pro menu font setting.
  hyprctl dispatch 'hl.dsp.exec_cmd("omarchy-restart-shell")' >/dev/null
  if ! pgrep -f '(^|/)nwg-dock-hyprland( |$)' >/dev/null; then
    hyprctl dispatch "hl.dsp.exec_cmd(\"uwsm-app -- $HOME/.local/bin/dock-start\")" >/dev/null
  fi
  errors=$(hyprctl configerrors)
  if [[ -n $errors && $errors != "ok" ]]; then
    echo "Hyprland reports config errors:" >&2
    echo "$errors" >&2
  fi
else
  echo "Hyprland is not running. Log in to apply everything."
fi

if [[ ! -f $HOME/.config/omarchy/projects.json ]]; then
  echo
  echo "Add your projects: copy $REPO/projects.example.json to"
  echo "~/.config/omarchy/projects.json, edit it, then run projects-apply."
fi

echo "Done. Open Super+Space → Learn → My Workspace for the guide."
