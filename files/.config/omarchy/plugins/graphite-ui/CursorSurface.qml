import QtQuick
import QtQuick.Effects

// Row background. The keyboard cursor and hover lift the row (lift fill, top
// highlight, small shadow). "Current" (for example the connected network) is
// not a fill in Graphite; the row shows it with status text instead.
// Keeps the properties of Omarchy's CursorSurface.
Item {
  id: root

  property bool hasCursor: false
  property bool current: false
  property bool outline: false
  property bool bordered: false

  property color foreground: Tokens.text2
  property color accent: Tokens.accent
  property color fill: Tokens.lift
  property color currentFill: "transparent"
  property int radius: Tokens.radiusRow

  // BorderSurface compatibility for callers that read these.
  property var borderSpec: null
  property color color: "transparent"
  readonly property real borderTop: 0
  readonly property real borderRight: 0
  readonly property real borderBottom: 0
  readonly property real borderLeft: 0

  // The lift fades in 80ms as one layer: fill, top highlight and shadow share
  // one opacity. (Animating the fill from "transparent", which is black at
  // zero alpha, passes through dark grey and flickers.)
  readonly property real _lift: hasCursor ? 1 : 0
  property real liftOpacity: _lift
  Behavior on liftOpacity { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

  Rectangle {
    anchors.fill: parent
    visible: root.current && !root.hasCursor && root.currentFill.a > 0
    radius: root.radius
    color: root.currentFill
  }

  RectangularShadow {
    anchors.fill: surface
    opacity: root.liftOpacity
    visible: opacity > 0
    radius: root.radius
    offset.y: 2
    blur: 8
    color: Qt.rgba(0, 0, 0, 0.4)
  }

  Rectangle {
    id: surface
    anchors.fill: parent
    radius: root.radius
    color: root.fill
    opacity: root.liftOpacity
    visible: opacity > 0

    Rectangle {
      anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: root.radius; rightMargin: root.radius }
      height: 1
      color: Tokens.highlight
    }
  }
}
