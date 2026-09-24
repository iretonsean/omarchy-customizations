pragma Singleton
import QtQuick
import qs.Commons

// Graphite tokens (docs/theme-direction.md) from the [graphite] section of
// shell.toml, with the Graphite values as fallbacks.
QtObject {
  id: root

  function parseColor(raw, fallback) {
    var s = String(raw || "").trim()
    var rgba = s.match(/^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)$/)
    if (rgba) return Qt.rgba(rgba[1] / 255, rgba[2] / 255, rgba[3] / 255, rgba[4] === undefined ? 1 : Number(rgba[4]))
    var hex = s.match(/^#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$/)
    if (hex) {
      var h = hex[1]
      return Qt.rgba(parseInt(h.substr(0, 2), 16) / 255, parseInt(h.substr(2, 2), 16) / 255,
                     parseInt(h.substr(4, 2), 16) / 255, hex[2] ? parseInt(hex[2], 16) / 255 : 1)
    }
    return fallback
  }

  function token(name, fallback) {
    return parseColor(Color.shellValues["graphite." + name], fallback)
  }

  readonly property color surface0: token("surface-0", "#0e0e10")
  readonly property color surface1: token("surface-1", "#18181a")
  readonly property color surface2: token("surface-2", "#222224")
  readonly property color surface3: token("surface-3", "#2c2c2e")
  readonly property color lift: token("lift", "#303033")
  readonly property color text1: token("text-1", "#f5f5f7")
  readonly property color text2: token("text-2", "#e5e5e7")
  readonly property color text3: token("text-3", "#98989d")
  readonly property color text4: token("text-4", "#636366")
  readonly property color accent: token("accent", "#0a84ff")
  readonly property color accentSoft: token("accent-soft", "#6cb4ff")
  readonly property color onAccent: token("on-accent", "#0e0e10")
  readonly property color labelTint: token("label-tint", "#7d8aa3")
  readonly property color ok: token("ok", "#7fd48f")
  readonly property color warn: token("warn", "#ffcc66")
  readonly property color error: token("error", "#ff8078")
  readonly property color keycapEdge: token("keycap-edge", Qt.rgba(1, 1, 1, 0.14))
  readonly property color highlight: token("highlight", Qt.rgba(1, 1, 1, 0.06))

  readonly property string labelFont: "SF Pro Text"
  readonly property string valueFont: "SFMono Nerd Font Mono"

  readonly property int radiusPanel: 16
  readonly property int radiusGroup: 8
  readonly property int radiusRow: 6
  readonly property int radiusField: 5
  readonly property int padPanel: 16
  readonly property int padGroup: 4
  readonly property int gapRow: 2
  readonly property int gapGroup: 10
  readonly property int rowNav: 36
  readonly property int rowData: 30
  readonly property int rowGroupName: 26

  // Type scale from the brief.
  readonly property int sizePanelTitle: 15
  readonly property int sizeMeta: 11
  readonly property int sizeGroupName: 11
  readonly property int sizeNavRow: 14
  readonly property int sizeDataRow: 13
  readonly property int sizeValue: 12
}
