-- Graphite: rounded corners, soft shadows, thin borders, no blur.
local active_border_color = "rgba(0a84ffb3)"
local inactive_border_color = "rgba(ffffff14)"

-- Menus and popups use SF Pro. The bar and terminals keep the monospace font.
hl.env("OMARCHY_MENU_FONT", "SF Pro Text")

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    -- Continuous (squircle) corners. The shell menus follow this radius.
    rounding = 12,
    rounding_power = 3,

    shadow = {
      enabled = true,
      range = 18,
      render_power = 3,
      offset = { 0, 4 },
      color = "rgba(00000073)",
      color_inactive = "rgba(00000040)",
    },

    blur = {
      enabled = false,
    },
  },
})

-- Motion (docs/theme-direction.md, Motion). Hyprland has no springs, so these
-- curves stand in for them: graphiteMove for the move spring (about 350ms,
-- a hint of overshoot) and graphiteSnap for snap (about 160ms, none).
-- Windows open from 98% like the shell panels. The menu and the bar panels
-- animate themselves (Omarchy sets no_anim on their layers).
hl.curve("graphiteMove", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1.02 } } })
hl.curve("graphiteSnap", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3.5, bezier = "graphiteMove" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.5, bezier = "graphiteMove", style = "popin 98%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.6, bezier = "graphiteSnap", style = "popin 98%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.6, bezier = "graphiteSnap" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.6, bezier = "graphiteSnap" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.5, bezier = "graphiteMove" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.5, bezier = "graphiteMove", style = "popin 98%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.6, bezier = "graphiteSnap", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.6, bezier = "graphiteSnap" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.6, bezier = "graphiteSnap" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, bezier = "graphiteMove", style = "slidevert" })
