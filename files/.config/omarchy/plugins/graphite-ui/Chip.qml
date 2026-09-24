import QtQuick

// Chip: a small SF Pro 12px label, 24px high, for jump-to rows and filters.
// The current chip and the hovered chip get lift, not accent.
// A chip that is not enabled shows in text-4 and takes no clicks.
Item {
  id: root

  property string text: ""
  property bool current: false

  signal clicked()

  implicitWidth: label.implicitWidth + 20
  implicitHeight: 24

  CursorSurface {
    anchors.fill: parent
    hasCursor: root.enabled && (root.current || mouse.containsMouse)
  }

  Text {
    id: label
    anchors.centerIn: parent
    text: root.text
    textFormat: Text.PlainText
    font.family: Tokens.labelFont
    font.pixelSize: Tokens.sizeValue
    font.weight: root.current ? Font.DemiBold : Font.Normal
    color: !root.enabled ? Tokens.text4 : (root.current || mouse.containsMouse ? Tokens.text1 : Tokens.text3)
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: if (root.enabled) root.clicked()
  }
}
