import QtQuick

// Keycap (docs/theme-direction.md): one per key, 20px high, 1px keycap-edge
// outline with a 2px bottom edge, 5px radius, SF Mono 11px in text-2.
// Use words for super, alt, ctrl and esc; symbols for ⇧ and ↵.
Item {
  id: root

  property string text: ""
  property color textColor: Tokens.text2

  implicitWidth: Math.max(20, label.implicitWidth + 12)
  implicitHeight: 20

  Rectangle {
    anchors.fill: parent
    radius: Tokens.radiusField
    color: "transparent"
    border.width: 1
    border.color: Tokens.keycapEdge
  }

  // The thicker bottom edge.
  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Tokens.radiusField
    anchors.rightMargin: Tokens.radiusField
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 1
    height: 1
    color: Tokens.keycapEdge
  }

  Text {
    id: label
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -1
    text: root.text
    textFormat: Text.PlainText
    font.family: Tokens.valueFont
    font.pixelSize: 11
    color: root.textColor
  }
}
