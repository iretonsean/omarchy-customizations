import QtQuick

// No lines in Graphite: tone and space separate sections. This keeps the
// properties of Omarchy's PanelSeparator but draws nothing and takes no
// height; the surrounding column's spacing makes the gap.
Item {
  property color foreground: Tokens.text2
  property real strength: 0

  width: parent ? parent.width : 0
  implicitWidth: 0
  implicitHeight: 0
  height: 0
  visible: false
}
