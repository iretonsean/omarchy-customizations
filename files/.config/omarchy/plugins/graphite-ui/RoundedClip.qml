import QtQuick
import QtQuick.Effects

// Rounded clip for anything that hides overflow (a scrolling list, a sliding
// row). A plain `clip: true` cuts content with square corners, so a group cut
// by the edge ends square. Use it on the clipped item:
//
//   clip: true
//   layer.enabled: true
//   layer.effect: G.RoundedClip {}
//
// `radius` defaults to the group radius (8px).
MultiEffect {
  id: root

  property real radius: Tokens.radiusGroup

  maskEnabled: true
  maskThresholdMin: 0.5
  maskSpreadAtMin: 1.0
  maskSource: mask

  Item {
    id: mask
    width: root.width
    height: root.height
    layer.enabled: true
    layer.smooth: true
    visible: false

    Rectangle {
      anchors.fill: parent
      radius: root.radius
      color: "black"
      antialiasing: true
    }
  }
}
