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
