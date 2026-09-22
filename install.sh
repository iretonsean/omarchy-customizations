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
chmod +x "$HOME/.local/bin/project-open" "$HOME/.local/bin/projects-apply" "$HOME/.local/bin/dock-start"

echo "==> Projects"
"$HOME/.local/bin/projects-apply"

echo "==> Theme, fonts and cursor"
omarchy theme set graphite
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
