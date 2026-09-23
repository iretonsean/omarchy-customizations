-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Projects menu: open a Claude session, files or a terminal for a project.
o.bind("SUPER + D", "Projects", "omarchy-menu toggle projects")

-- Agents (workspace 1). SUPER+SHIFT+A was ChatGPT.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Claude", o.launch_webapp_sole("chrome-claude\\.ai__new", "https://claude.ai/new"))
o.bind("SUPER + SHIFT + T", "T3 Code", { focus = "^com\\.t3tools\\.T3Code$", launch = "gtk-launch com.t3tools.T3Code" })

-- Design (workspace 4).
o.bind("SUPER + SHIFT + I", "Figma", o.launch_webapp_sole("chrome-www\\.figma\\.com__", "https://www.figma.com/files"))
o.bind("SUPER + SHIFT + ALT + I", "Paper", o.launch_webapp_sole("chrome-app\\.paper\\.design__", "https://app.paper.design"))
o.bind("SUPER + SHIFT + CTRL + I", "Claude Design", o.launch_webapp_sole("chrome-claude\\.ai__design", "https://claude.ai/design"))

-- Super+Ctrl+Shift+4: select an area and copy the screenshot to the clipboard (no file).
o.bind("SUPER + CTRL + SHIFT + code:13", "Screenshot area to clipboard", "omarchy-capture-screenshot region copy")

-- Super+V in a terminal: paste an image into a coding agent.
-- Omarchy's universal paste sends Shift+Insert to terminals, which pastes text
-- only. In a terminal, run ~/.local/bin/terminal-paste in the background: it
-- sends Ctrl+V when the clipboard holds an image (terminal agents such as
-- Claude Code read images on Ctrl+V) and Shift+Insert for text. Never check
-- the clipboard here: Hyprland would wait for wl-paste, which waits for
-- Hyprland, and the screen freezes.
local function send_shortcut_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  for _, tag in ipairs(window and window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

hl.unbind("SUPER + V")
o.bind("SUPER + V", "Universal paste (images too)", function()
  if active_window_is_terminal() then
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/terminal-paste")
  else
    send_shortcut_once("CTRL", "V")
  end
end)
